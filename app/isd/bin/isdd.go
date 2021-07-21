package main

import (
	"archive/tar"
	"compress/gzip"
	"encoding/csv"
	"flag"
	"fmt"
	"io"
	"os"
	"runtime/pprof"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/sirupsen/logrus"
)

// Usage will print usage and exit
func Usage() {
	fmt.Println(`
NAME
	isdd -- Intergrated Surface Dataset Daily Dataset Parser

SYNOPSIS
	isdd [-i <input|stdin>] [-o <output|st>] -p -d -c -v

DESCRIPTION
	The isdd program takes isd daily (yearly tarball file) as input.
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
	ID             string // 0 Station ID
	Date           string // 1 UTC Date
	TempMean       string // 6 Mean temperature for the day in degrees	Fahrenheit to tenths.  Missing = 9999.9
	TempMeanCnt    string // 7 Number of observations used in calculating mean temperature
	DewpMean       string // 8 Mean dew point for the day in degrees	Fahrenheit to tenths.  Missing = 9999.9
	DewpMeanCnt    string // 9
	SlpMean        string // 10 Mean sea level pressure for the day in millibars to tenths Missing = 9999.9
	SlpCnt         string // 11
	StpMean        string // 12 Mean station pressure for the day	in millibars to tenths.  Missing = 9999.9
	StpCnt         string // 13
	VisibMean      string // 14
	VisibCnt       string // 15
	WdspMean       string // 16 wind speed
	WdspCount      string // 17
	WdspMax        string // 18
	Gust           string // 19
	TempMax        string // 20
	TempMaxFlag    string // 21
	TempMin        string // 22
	TempMinFlag    string // 23
	Preciptitation string // 24
	PrcpFlag       string // 25 A B C D E F G H I
	Sndp           string // 26 Snow depth in inches to tenths
	FRSHTT         string // 27 Fog Rain Snow Hail Thunder Tornado
	prcp           string // derived field
}

// ParseRecord turns observation records into Record structure
func ParseRecord(d []string) (r *Record) {
	r = &Record{
		ID:             d[0],                                             // string // 0 Station ID
		Date:           d[1],                                             // string // 1 UTC Date
		TempMean:       ParseTemperature(d[6]),                           // string // 6 Mean temperature for the day in degrees	Fahrenheit to tenths.  Missing = 9999.9
		TempMeanCnt:    ParseInt(d[7]),                                   // string // 7 Number of observations used in calculating mean temperature
		DewpMean:       ParseTemperature(d[8]),                           // string // 8 Mean dew point for the day in degrees	Fahrenheit to tenths.  Missing = 9999.9
		DewpMeanCnt:    ParseInt(d[9]),                                   // string // 9
		SlpMean:        ParseMetricScale(d[10], "9999.9", 1, 1),          // string // 10 Mean sea level pressure for the day in millibars to tenths Missing = 9999.9
		SlpCnt:         ParseInt(d[11]),                                  // string // 11
		StpMean:        ParseMetricScale(d[12], "9999.9", 1, 1),          // string // 12 Mean station pressure for the day	in millibars to tenths.  Missing = 9999.9
		StpCnt:         ParseInt(d[13]),                                  // string // 13
		VisibMean:      ParseMetricScale(d[14], "999.9", 1609.344, 0),    // string // 14
		VisibCnt:       ParseInt(d[15]),                                  // string // 15
		WdspMean:       ParseMetricScale(d[16], "999.9", 0.514444444, 1), // string // 16 wind speed
		WdspCount:      ParseInt(d[17]),                                  // string // 17
		WdspMax:        ParseMetricScale(d[18], "999.9", 0.514444444, 1), // string // 18
		Gust:           ParseMetricScale(d[19], "999.9", 0.514444444, 1), // string // 19
		TempMax:        ParseTemperature(d[20]),                          // string // 20
		TempMaxFlag:    strings.Trim(d[21], " "),                         // string // 21
		TempMin:        ParseTemperature(d[22]),                          // string // 22
		TempMinFlag:    strings.Trim(d[23], " "),                         // string // 23
		Preciptitation: ParseMetricScale(d[24], "99.99", 25.4, 1),        // string // 24
		PrcpFlag:       strings.Trim(d[25], " "),                         // string // 25 A B C D E F G H I
		Sndp:           ParseMetricScale(d[26], "999.9", 25.4, 0),        // string // 26 Snow depth in inches to tenths
		FRSHTT:         strings.Trim(d[27], " "),                         // string // 27 Fog Rain Snow Hail Thunder Tornado
	}

	if r.TempMaxFlag == "*" {
		r.TempMaxFlag = "t"
	} else {
		r.TempMaxFlag = "f"
	}

	if r.TempMinFlag == "*" {
		r.TempMinFlag = "t"
	} else {
		r.TempMinFlag = "f"
	}

	if r.StpMean == "999.9" {
		r.StpMean = ""
	}

	if r.Preciptitation != "" {
		v, _ := strconv.ParseFloat(r.Preciptitation, 64)
		var prcpFactor = 1.0
		switch r.PrcpFlag {
		case "A":
			prcpFactor = 4.0
		case "B":
			prcpFactor = 2.0
		case "C":
			prcpFactor = 1.333333333
		case "E":
			prcpFactor = 2.0
		case "D":
			fallthrough
		case "F":
			fallthrough
		case "G":
			fallthrough
		case "H":
			fallthrough
		case "I":
			fallthrough
		default:
			prcpFactor = 1.0
		}
		r.prcp = strconv.FormatFloat(v*prcpFactor, 'f', 1, 32)
	}

	return
}

// [STATION DATE LATITUDE LONGITUDE ELEVATION NAME TEMP TEMP_ATTRIBUTES DEWP DEWP_ATTRIBUTES SLP SLP_ATTRIBUTES STP STP_ATTRIBUTES VISIB VISIB_ATTRIBUTES WDSP WDSP_ATTRIBUTES MXSPD GUST MAX MAX_ATTRIBUTES MIN MIN_ATTRIBUTES PRCP PRCP_ATTRIBUTES SNDP FRSHTT]

// Parse metrics into
func ParseMetric(metric, missingValue string, scale int) (res string) {
	metric = strings.Trim(metric, " ")
	if metric == missingValue {
		return ""
	}
	v, err := strconv.ParseInt(metric, 10, 64)
	if err != nil {
		logrus.Errorf("malformed metric %s", metric)
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

func ParseMetricScale(metric, missingValue string, scale float64, prec int) (res string) {
	metric = strings.Trim(metric, " ")
	if metric == missingValue {
		return ""
	}
	v, err := strconv.ParseFloat(metric, 64)
	if err != nil {
		logrus.Errorf("malformed metric %s", metric)
		return ""
	}
	return strconv.FormatFloat(float64(v)*scale, 'f', prec, 32)
}

func ParsePressure(pStr string) (res string) {
	pStr = strings.Trim(pStr, " ")
	if pStr == "9999.9" {
		return ""
	}
	v, err := strconv.ParseFloat(pStr, 64)
	if err != nil {
		logrus.Errorf("malformed pressure %s", pStr)
		return ""
	}
	return strconv.FormatFloat(v, 'f', 1, 32) // millibar = hPa = 100 pascal
}

func ParseTemperature(tempStr string) (res string) {
	tempStr = strings.Trim(tempStr, " ")
	if tempStr == "9999.9" {
		return ""
	}
	v, err := strconv.ParseFloat(tempStr, 64)
	if err != nil {
		logrus.Errorf("malformed temperature %s", tempStr)
		return ""
	}
	v = (v - 32.0) * 5 / 9.0
	return strconv.FormatFloat(v, 'f', 1, 32)
}

func ParseInt(intStr string) (res string) {
	v, err := strconv.ParseInt(strings.Trim(intStr, " "), 10, 32)
	if err != nil {
		logrus.Errorf("malformed integer %s", intStr)
		return ""
	}
	return strconv.FormatInt(v, 10)
}

func (r *Record) FormatRecord() []string {
	return []string{
		r.ID,        // 0 string 0 Station ID
		r.Date,      // 1 string 1 UTC Date
		r.TempMean,  // 2 string 6 Mean temperature for the day in degrees	Fahrenheit to tenths.  Missing = 9999.9
		r.TempMin,   // 3 string 22
		r.TempMax,   // 4 string 20
		r.DewpMean,  // 5 string 8 Mean dew point for the day in degrees	Fahrenheit to tenths.  Missing = 9999.9
		r.SlpMean,   // 6 string 10 Mean sea level pressure for the day in millibars to tenths Missing = 9999.9
		r.StpMean,   // 7 string 12 Mean station pressure for the day	in millibars to tenths.  Missing = 9999.9
		r.VisibMean, // 8 string 14

		r.WdspMean, // 9 string 16 wind speed
		r.WdspMax,  // 10 string 18
		r.Gust,     // 11 string 19

		r.Preciptitation, // 12 string 24
		r.prcp,           // 13
		r.Sndp,           // 14 string 26 Snow depth in inches to tenths

		string(r.FRSHTT[0]), // string 27 Fog Rain Snow Hail Thunder Tornado
		string(r.FRSHTT[1]), // string 27 Fog Rain Snow Hail Thunder Tornado
		string(r.FRSHTT[2]), // string 27 Fog Rain Snow Hail Thunder Tornado
		string(r.FRSHTT[3]), // string 27 Fog Rain Snow Hail Thunder Tornado
		string(r.FRSHTT[4]), // string 27 Fog Rain Snow Hail Thunder Tornado
		string(r.FRSHTT[5]), // string 27 Fog Rain Snow Hail Thunder Tornado

		r.TempMeanCnt, // string 7 Number of observations used in calculating mean temperature
		r.DewpMeanCnt, // string 9
		r.SlpCnt,      // string 11
		r.StpCnt,      // string 13
		r.VisibCnt,    // string 15
		r.WdspCount,   // string 17

		r.TempMaxFlag, // string 21
		r.TempMinFlag, // string 23
		r.PrcpFlag,    // string 25 A B C D E F G H I
	}
}

/**********************************************************************\
*                           Station                                    *
\**********************************************************************/
type Station struct {
	ID               string
	Date             string
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
	header := data[1]
	s.ID = header[0]
	s.USAF = header[0][0:6]
	s.WBAN = header[0][6:]
	s.Date = header[1]
	s.Name = header[5]
	lon, _ := strconv.ParseFloat(header[3], 64)
	lat, _ := strconv.ParseFloat(header[2], 64)
	elev, _ := strconv.ParseFloat(header[4], 64)
	s.Longitude = lon
	s.Latitude = lat
	s.Elevation = elev

	data = data[1:]
	s.Data = make([]*Record, len(data)) // remove csv header
	for i, item := range data {         // start from 2nd record if exists
		s.Data[i] = ParseRecord(item)
	}

	return
}

// ParseDataRaw
func (s *Station) ParseDataRaw(data [][]string) {
	s.Data = make([]*Record, len(data)) // remove csv header
	for i, item := range data {         // start from 2nd record if exists
		s.Data[i] = ParseRecord(item)
	}
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
	p := NewProcessor(`/Volumes/Data/noaa/data/daily/2020.tar.gz`, `/tmp/record.csv`)
	if err := p.Run(); err != nil {
		panic(err)
	}
}

func main() {
	Main()
}
