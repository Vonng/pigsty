package main

import (
	"archive/tar"
	"compress/gzip"
	"encoding/csv"
	"encoding/json"
	"flag"
	"fmt"
	"github.com/sirupsen/logrus"
	"io"
	"os"
	"runtime/pprof"
	"strconv"
	"strings"
	"sync"
	"time"
)

// Usage will print usage and exit
func Usage() {
	fmt.Println(`
NAME
	isdh -- Intergrated Surface Dataset Hourly Parser

SYNOPSIS
	isdh [-i <input|stdin>] [-o <output|st>] -p -d -c -v

DESCRIPTION
	The isdh program takes isd hourly (yearly tarball file) as input.
	And generate csv format as output

OPTIONS
	-i	<input>		input file, stdin by default
	-o	<output>	output file, stdout by default
	-p	<profpath>	pprof file path (disable by default)	
	-v				verbose progress report
	-d				de-duplicate rows (raw, ts-first, hour-first)
	-c				add comma separated extra columns
`)
	os.Exit(0)
}

/**********************************************************************\
*                           Record                                     *
\**********************************************************************/
type Record struct {
	ID           string // station ID
	TS           string // timestamp in UTC
	WindAngle    string // x1 The angle, measured in a clockwise direction, between true north and the direction from which the wind is blowing.
	WindSpeed    string // x10 The rate of horizontal travel of air past a fixed point.
	WindTypeCode string // ABCHNRQTV9 The code that denotes the character of the WIND-OBSERVATION.

	CloudHeight     string // x1 0-22000 The height above ground level (AGL) of the lowest cloud or obscuring phenomena layer aloft with 5/8 or more summation total sky cover, which may be predominantly opaque, or the vertical visibility into a surface-based obstruction
	CloudMethodCode string // ABCDEMPRSUVW9
	CloudCAVOK      string // N Y 9 The code that represents whether the 'Ceiling and Visibility Okay' (CAVOK) condition has been reported.

	VisDistance string // x1 0-160000  The horizontal distance at which an object can be seen and identified.
	VisVariable string // N Y 9 N: not variable  V: variable  9: Missing

	Temperature string // x10 -932 ~ +618 The temperature of the air.
	DewPoint    string // x10 -982 ~ +368 The temperature to which a given parcel of air must be cooled at constant pressure and water vapor content in order for saturation to occur.
	Pressure    string // x10  8600-10900 Hectopascals

	// quality control field
	WindAngleQC   byte // quality code for WindAngle
	WindSpeedQC   byte // quality code for WindSpeed
	CloudHeightQC byte // quality code for CloudHeight
	VisDistanceQC byte // quality code for VisDistance
	VisVariableQC byte // quality code for VisVariable
	DewPointQC    byte // quality code for DewPointQC
	TemperatureQC byte // quality code for TemperatureQC
	PressureQC    byte // quality code for Pressure

	// additional fields
	CloudCode         string // CHAR(2)
	StationPressure   string // NUMERIC(5,1)
	WeatherManual     string // CHAR(2)
	WeatherPresent    string // CHAR(2)
	WeatherPast       string // CHAR
	WeatherPastHour   string // NUMERIC(2)
	Precipitation     string // NUMERIC(4,1)
	PrecipitationHour string // NUMERIC(2)
	PrecipitationCode string // CHAR
	Gust              string // NUMERIC(4,1)
	SnowDepth         string // NUMERIC(4,1)

	Remark string // remark data
	EQD    string // element quality
	Data   string // json data additional fields are treated as json
}

// Parse metrics into
func ParseMetric(metric, missingValue string, scale int) (res string) {
	if metric == missingValue {
		return ""
	}
	v, err := strconv.ParseInt(metric, 10, 64)
	if err != nil {
		return ""
	}
	switch scale {
	case 1:
		return strconv.FormatInt(v, 10)
	case 10:
		return strconv.FormatFloat(float64(v)/10, 'f', 1, 32)
	case 100:
		return strconv.FormatFloat(float64(v)/100, 'f', 2, 32)
	case 1000:
		return strconv.FormatFloat(float64(v)/1000, 'f', 3, 32)
	}
	return ""
}

func (r *Record) QualityCodes() string {
	return string([]byte{
		r.WindAngleQC,
		r.WindSpeedQC,
		r.CloudHeightQC,
		r.VisDistanceQC,
		r.VisVariableQC,
		r.TemperatureQC,
		r.DewPointQC,
		r.PressureQC,
	})
}

func (r *Record) FormatRecord() []string {
	return []string{
		r.ID,              // 0 station    	VARCHAR(12)
		r.TS,              // 1 ts         	TIMESTAMP
		r.Temperature,     // 2 temp   		NUMERIC(3, 1),        -- x10 [-93.2,+61.8]
		r.DewPoint,        // 3 dewp     	NUMERIC(3, 1),        -- x10 [-98.2,+36.8]
		r.Pressure,        // 4 slp      	NUMERIC(5, 1),        -- x10 [8600,10900]
		r.StationPressure, // 5 stp			NUMERIC(5, 1),
		r.VisDistance,     // 6 vis  		NUMERIC(6)       [0,160000]
		r.WindAngle,       // 7 wd_angle	NUMERIC(3)
		r.WindSpeed,       // 8 wd_speed	NUMERIC(4, 1)
		r.Gust,            // 9 wd_gust		NUMERIC(4, 1)
		r.WindTypeCode,    // 10 wd_code	VARCHAR(1)
		r.CloudHeight,     // 11 cld_height  NUMERIC(5) [0,22000]
		r.CloudCode,       // 12 cld_code VARCHAR(2)
		r.SnowDepth,
		r.Precipitation,
		r.PrecipitationHour,
		r.PrecipitationCode,
		r.WeatherManual,
		r.WeatherPresent,
		r.WeatherPast,
		r.WeatherPastHour,
		// r.Remark,
		// r.EQD,
		r.Data,
	}
}

/**********************************************************************\
*                           Station                                    *
\**********************************************************************/
type Station struct {
	ID               string
	Year             string
	Source           string // may vary
	USAF             string
	WBAN             string
	Name             string
	Longitude        float64
	Latitude         float64
	Elevation        float64
	ReportType       string // may vary
	CallSign         string // may vary
	QualityControl   string // may vary
	AdditionalFields []string
	Data             []*Record
}

func ParseStation(data [][]string, dedupeMode string) (s *Station) {
	s = &Station{}
	header := data[0]
	lon, _ := strconv.ParseFloat(header[4], 64)
	lat, _ := strconv.ParseFloat(header[3], 64)
	elev, _ := strconv.ParseFloat(header[5], 64)
	s.ID = header[0]
	s.Year = header[1][0:4]
	s.Source = header[2]
	s.USAF = header[0][0:6]
	s.WBAN = header[0][6:]
	s.Name = header[6]
	s.Longitude = lon
	s.Latitude = lat
	s.Elevation = elev
	s.ReportType = header[7]
	s.CallSign = header[8]
	s.QualityControl = header[9]
	if len(header) > 16 {
		s.AdditionalFields = header[16:] // get header additional fields names
	}

	switch dedupeMode {
	case "ts-first":
		s.ParseDataTsFirst(data[1:])
	case "raw":
		s.ParseDataRaw(data[1:])
	default:
		s.ParseDataRaw(data[1:])
	}

	return
}

func (s *Station) ParseRecord(d []string) (r *Record) {
	r = &Record{}
	r.ID = d[0]
	r.TS = d[1]

	// Wind Data (5 fields) [angle, angle-qc, type, speed, speed-qc]
	wind := strings.SplitN(d[10], ",", 5)
	r.WindAngle = ParseMetric(wind[0], "999", 1)
	if wind[3] == "0000" && wind[2] == "9" {
		r.WindTypeCode = "C" // a value of 9 appears with a wind speed of 0000, this indicates calm winds
	} else {
		r.WindTypeCode = wind[2]
	}
	r.WindSpeed = ParseMetric(wind[3], "9999", 10)
	r.WindAngleQC = byte(wind[1][0])
	r.WindSpeedQC = byte(wind[4][0])

	// CIG Data (4 fields)  [height, height-qc method, cavok]
	cloud := strings.SplitN(d[11], ",", 4)
	r.CloudHeight = ParseMetric(cloud[0], "99999", 1) // x1 0-22000
	r.CloudHeightQC = byte(cloud[1][0])               // 9 = missing
	r.CloudMethodCode = string(cloud[2])              // ABCDEMPRSUVW9
	r.CloudCAVOK = cloud[3]
	if r.CloudCAVOK != "N" && r.CloudCAVOK != "Y" {
		r.CloudCAVOK = ""
	}

	// VIS Data (4 pieces) [distance, distance-qc, variability code, var code qc]
	visbility := strings.SplitN(d[12], ",", 4)
	r.VisDistance = ParseMetric(visbility[0], "999999", 1)
	r.VisDistanceQC = byte(visbility[1][0]) // 9 = missing
	r.VisVariableQC = byte(visbility[3][0])
	r.VisVariable = visbility[2] // N Y 9
	if r.VisVariable != "N" && r.VisVariable != "Y" {
		r.VisVariable = ""
	}

	// TMP DEW SLP Data: (2 pieces) [value, value-qc]
	airTemperature := strings.SplitN(d[13], ",", 2)
	dewPoint := strings.SplitN(d[14], ",", 2)
	seaLevelPressure := strings.SplitN(d[15], ",", 2)
	r.TemperatureQC = byte(airTemperature[1][0])                // 9 = missing
	r.DewPointQC = byte(dewPoint[1][0])                         // 9 = missing
	r.PressureQC = byte(seaLevelPressure[1][0])                 // 9 = missing
	r.Temperature = ParseMetric(airTemperature[0], "+9999", 10) // x10  -932 ~ 618
	r.DewPoint = ParseMetric(dewPoint[0], "+9999", 10)          // x10  -932 ~ 618
	r.Pressure = ParseMetric(seaLevelPressure[0], "99999", 10)  // x10  -932 ~ 618

	data := make(map[string]string, len(s.AdditionalFields))
	// add mandatory data to dict
	data["WND"], data["CIG"], data["VIS"], data["TMP"], data["DEW"], data["SLP"] = d[10], d[11], d[12], d[13], d[14], d[15]

	// process additional fields
	var key, value string
	for i := 16; i < len(d); i++ {
		key, value = s.AdditionalFields[i-16], d[i]
		if value == "" {
			continue
		}

		switch key {
		case "GF1": // 云量 oktas
			data[key] = value
			cloudCode, cloudCodeQC := value[0:2], value[6]
			if cloudCode == "99" || cloudCodeQC == '3' || cloudCodeQC == '7' {
				continue
			}
			r.CloudCode = value[0:2]
		case "MA1": // 站点气压
			data[key] = value
			r.StationPressure = ParseMetric(value[8:13], "99999", 10)
		case "MW1": // 人工观测的气象
			data[key] = value
			if value[3] == '3' || value[3] == '7' {
				continue
			}
			r.WeatherManual = value[0:2]
		case "AW1": // 自动生产的当前天气代码
			data[key] = value
			if value[3] == '3' || value[3] == '7' {
				continue
			}
			r.WeatherPresent = value[0:2]
		case "AY1": // 自动生成的过去一段时间的天气代码
			data[key] = value
			if value[3] == '3' || value[3] == '7' {
				continue
			}
			r.WeatherPast = value[0:1]
			r.WeatherPastHour = ParseMetric(value[4:6], "99", 1)
		case "AA1", "AA2", "AA3", "AA4": // 降水data[key] = value
			data[key] = value
			if value[10] == '3' || value[10] == '7' || value[8] == '1' || value[8] == '9' || value[0:2] == "99" {
				continue // skip error and missing record
			}

			if r.Precipitation == "" { // empty, fill it
				r.Precipitation = ParseMetric(value[3:7], "9999", 10)
				if r.Precipitation != "" {
					r.PrecipitationHour = ParseMetric(value[0:2], "99", 1)
					r.PrecipitationCode = value[8:9]
				}
			} else { // already have a record, fill it will longer prcp record
				if strings.Compare(value[0:2], r.Precipitation) > 0 {
					r.Precipitation = ParseMetric(value[3:7], "9999", 10)
					if r.Precipitation != "" {
						r.PrecipitationHour = ParseMetric(value[0:2], "99", 1)
						r.PrecipitationCode = value[8:9]
					}
				}
			}
		case "OC1": // Gust
			data[key] = value
			if value[5] == '3' || value[5] == '7' {
				continue
			}
			r.Gust = ParseMetric(value[0:4], "9999", 10)
		case "AJ1": // 雪深
			data[key] = value
			if value[7] == '3' || value[7] == '7' {
				continue
			}
			r.SnowDepth = ParseMetric(value[9:15], "999999", 10)
		case "REM": // 备注
			// r.Remark = value (some station report dirty data so in some case we just omit remarks)
		case "EQD": // 处理
			// r.EQD = value  (some station report dirty data so in some case we just omit remarks)
		default: // 其他字段
			data[key] = value
		}
	}
	if jsonStr, err := json.Marshal(data); err != nil {
		logrus.Errorf("json marshal error %s", err.Error())
	} else {
		r.Data = string(jsonStr)
	}
	return
}

// ParseDataRaw
func (s *Station) ParseDataRaw(data [][]string) {
	s.Data = make([]*Record, len(data)) // remove csv header
	for i, item := range data {         // start from 2nd record if exists
		s.Data[i] = s.ParseRecord(item)
	}
}

// ParseDataTS will dedupe record with same station and timestamp by just picking the first record
func (s *Station) ParseDataTsFirst(data [][]string) {
	if len(data) == 0 {
		s.Data = []*Record{}
		return
	}

	var res []*Record
	var lastRecord, record *Record
	for i, item := range data { // start from 2nd record if exists
		record = s.ParseRecord(item)
		if i == 0 {
			lastRecord = record
			res = append(res, record)
			continue
		}

		if record.TS == lastRecord.TS {
			continue // discard record with same ts
		}
		res = append(res, record)
		lastRecord = record
	}
	s.Data = res
}

func (s *Station) CSV() [][]string {
	var res [][]string
	for _, r := range s.Data {
		res = append(res, r.FormatRecord())
	}
	return res
}

func (s *Station) WriteCSV(w io.Writer) (err error) {
	cw := csv.NewWriter(w)
	defer cw.Flush()
	for _, r := range s.Data {
		if err = cw.Write(r.FormatRecord()); err != nil {
			return err
		}
	}
	return nil
}

/**********************************************************************\
*                          Processor                                   *
\**********************************************************************/

type Processor struct {
	// I/O
	SourcePath string // stdin by default
	OutputPath string // stdout by default
	DataChan   chan [][]string

	SourceFile *os.File
	OutputFile *os.File

	wg sync.WaitGroup

	// Parameters
	Verbose      bool
	DedupeMode   string
	ExtraColumns []string

	// Statistic
	readerFileCnt int
	readerByteCnt int
	readerLineCnt int
	writerFileCnt int
	writerByteCnt int
	writerLineCnt int
	StartAt       time.Time
}

func NewProcessor(args ...string) (p *Processor) {
	p = &Processor{}
	if len(args) > 0 {
		p.SourcePath = args[0]
		if p.SourcePath == "" {
			p.SourcePath = "stdin"
		}
	}
	if len(args) > 0 {
		p.OutputPath = args[1]
		if p.OutputPath == "" {
			p.OutputPath = "stdout"
		}
	}
	p.DataChan = make(chan [][]string, 64)
	return p
}

func (p *Processor) Run() error {
	p.StartAt = time.Now()
	logrus.Infof("Processor [%s] [%s], %s -> %s init", p.DedupeMode, strings.Join(p.ExtraColumns, ","), p.SourcePath, p.OutputPath)

	p.wg.Add(2)
	go p.Writer()
	go p.Reader()
	if p.Verbose {
		go p.Reporter()
	}

	p.wg.Wait()
	logrus.Infof("Process done")
	return nil
}

func (p *Processor) Reporter() {
	ticker := time.NewTicker(time.Second)
	defer ticker.Stop()
	for {
		select {
		case <-ticker.C:
			logrus.Infof("[F: %5d -> %-5d] [L: %10d -> %-10d] [B: %10s] [Q: %5d]",
				p.readerFileCnt, p.writerFileCnt, p.readerLineCnt, p.writerLineCnt, ByteCountIEC(p.readerByteCnt), len(p.DataChan))
		}
	}
}

func (p *Processor) Writer() {
	var err error
	if p.OutputPath == "stdout" {
		p.OutputFile = os.Stdout
	} else {
		if p.OutputFile, err = os.Create(p.OutputPath); err != nil {
			panic(err)
		}
	}
	defer p.OutputFile.Close()

	logrus.Infof("Writer %s init", p.OutputPath)
	for data := range p.DataChan {
		station := ParseStation(data, p.DedupeMode)
		if err = station.WriteCSV(p.OutputFile); err != nil {
			logrus.Errorf("Writer %s exit", p.OutputPath)
			panic(err)
		}
		p.writerFileCnt += 1
		// p.writerByteCnt += int(hdr.Size)
		p.writerLineCnt += len(station.Data)
	}
	p.wg.Done()
	logrus.Infof("Writer %s done", p.OutputPath)

}

func (p *Processor) Reader() {
	var err error
	if p.SourcePath == "stdin" {
		p.SourceFile = os.Stdin
	} else {
		if p.SourceFile, err = os.Open(p.SourcePath); err != nil {
			panic(err)
		}
	}
	defer p.SourceFile.Close()

	// wrap source file with .tar.gz reader
	gr, err := gzip.NewReader(p.SourceFile)
	if err != nil && err != io.EOF {
		panic(err)
	}
	defer gr.Close()
	tr := tar.NewReader(gr)

	// reader main loop
	logrus.Infof("Reader %s init", p.SourcePath)
	for {
		// read next csv file
		hdr, err := tr.Next()
		if err != nil {
			if err == io.EOF {
				break
			} else {
				// TODO: Report error but skip to next
				continue
			}
		}
		if !(hdr.Typeflag == tar.TypeReg && strings.HasSuffix(hdr.Name, ".csv")) {
			continue // skip non csv file
		}

		// load csv records
		cr := csv.NewReader(tr)
		data, err := cr.ReadAll()
		if err != nil {
			// panic(err)
			continue
		}

		// Send to Input channel
		p.DataChan <- data

		// update statistic
		p.readerFileCnt += 1
		p.readerByteCnt += int(hdr.Size)
		p.readerLineCnt += len(data)

	}
	logrus.Infof("Reader %s done", p.SourcePath)

	close(p.DataChan)
	p.wg.Done()

}

func ByteCountIEC(b int) string {
	const unit = 1024
	if b < unit {
		return fmt.Sprintf("%d B", b)
	}
	div, exp := int64(unit), 0
	for n := b / unit; n >= unit; n /= unit {
		div *= unit
		exp++
	}
	return fmt.Sprintf("%.1f %ciB",
		float64(b)/float64(div), "KMGTPE"[exp])
}

var (
	inputPath    string // input path
	outputPath   string // output path
	profilePath  string // profile path (pprof)
	dedupeMode   string // dedupe level: raw | ts | hour
	extraColumns string // extra columns
	verbose      bool   // verbose mode
	help         bool   // help mode
)

func Main() {
	flag.StringVar(&inputPath, "i", `stdin`, "input file path (stdin by default)")
	flag.StringVar(&outputPath, "o", `stdout`, "output file path (stdout by default)")
	flag.StringVar(&profilePath, "p", ``, "pprof file path (disable by default)")
	flag.StringVar(&dedupeMode, "d", `raw`, "dedupe mode (raw|ts-first|hour-first)")
	flag.StringVar(&extraColumns, "c", ``, "comma separated extra column names")
	flag.BoolVar(&verbose, "v", false, "print progress report")
	flag.BoolVar(&help, "h", false, "print help information")
	flag.Parse()

	if help {
		Usage()
	}

	p := NewProcessor(inputPath, outputPath)
	p.Verbose = verbose
	p.DedupeMode = dedupeMode
	p.ExtraColumns = strings.Split(extraColumns, ",")

	// optional: performance profile
	if profilePath != "" {
		f, _ := os.Create(profilePath)
		pprof.StartCPUProfile(f)
		defer pprof.StopCPUProfile()
	}

	if err := p.Run(); err != nil {
		panic(err)
	}
}

func Test() {
	p := NewProcessor(`/Volumes/Data/noaa/data/hourly/2020.tar.gz`, `stdout`)
	if err := p.Run(); err != nil {
		panic(err)
	}
}

func main() {
	Main()
}
