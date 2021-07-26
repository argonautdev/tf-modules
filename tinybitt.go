package main

import (
	"bytes"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"strings"
	"text/template"

	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

type AWS struct {
	AWSArn       string
	Username     string
	AWSAccountID string
}

type BackendData struct {
	Username string
	Password string
	Host     string
}

type Organization struct {
	Name string
}

type Environment struct {
	Name   string
	Region string
}

type Cluster struct {
	Name string
}
type NodeGroup struct {
	// name of the environment
	Name string `json:"name"`

	// Instance type
	// @todo provide enum values for this
	InstanceType string `json:"instance_type"`

	// is the environment using spot
	Spot bool `json:"spot"`

	// scale automatically defaults to true
	AutoScale bool `json:"auto_scale" gorm:"default:true"`

	// current number of instance running max val 4,294,967,295
	NumberOfInstance uint `json:"number_of_instance"`

	// max number of instances running
	NumberOfInstanceMax uint `json:"number_of_instance_max"`

	// min number of instances running
	NumberOfInstanceMin uint `json:"number_of_instance_min"`

	// one env belongs to only one cluster and only one organization

	// the namespace this node group belongs to
	Namespace string `json:"namespace"`
	DiskSize  uint   `json:"disk_size"`
}

type VisibilityType string

const (
	VisibilityTypePublic  VisibilityType = "public"
	VisibilityTypePrivate VisibilityType = "private"
)

type RDS struct {
	Name          string
	Visibility    VisibilityType
	Identifier    string
	Engine        string
	EngineVersion string
	Storage       uint
	InstanceClass string
	Username      string
	Password      string
	Family        string
}

type AwsS3StaticSite struct {
	Name       string         `json:"name" yaml:"name"`
	Visibility VisibilityType `json:"visibility" yaml:"visibility"`

	Website       string `json:"website" yaml:"website"`
	LogBucketName string `json:"logBucketName" yaml:"logBucketName"`
	IndexDocument string `json:"indexDocument" yaml:"indexDocument"`
	ErrorDocument string `json:"errorDocument" yaml:"errorDocument"`
}

type AwsS3Bucket struct {
	Name       string         `json:"name" yaml:"name"`
	Visibility VisibilityType `json:"visibility" yaml:"visibility"`
}

type Config struct {
	Environment     *Environment
	Cluster         *Cluster
	NodeGroup       *NodeGroup
	RDS             *RDS
	AWS             *AWS
	AwsS3Bucket     *AwsS3Bucket
	AwsS3StaticSite *AwsS3StaticSite
	BackendData     *BackendData
	Organization    *Organization
	RefVersion      string
}

func getConfig() *Config {
	awsArn := "arn:aws:iam::054565121117:user/surya"
	splitted := strings.Split(awsArn, "/")
	return &Config{
		Environment: &Environment{
			Name:   "bheem",
			Region: "us-east-1",
		},
		Cluster: &Cluster{
			Name: "bheem",
		},
		NodeGroup: &NodeGroup{
			Name:                "bheem",
			InstanceType:        "t3.medium",
			Spot:                true,
			AutoScale:           false,
			NumberOfInstance:    3,
			NumberOfInstanceMax: 3,
			NumberOfInstanceMin: 1,
			DiskSize:            20,
		},
		RDS: &RDS{
			Name:          "bheempostgres",
			Visibility:    VisibilityTypePrivate,
			Identifier:    "bheempostgres",
			Engine:        "postgres",
			Family:        "postgres11",
			EngineVersion: "11.10",
			InstanceClass: "db.t3.small",
			Storage:       10,
			Username:      "god",
			Password:      "admin123456",
		},
		AWS: &AWS{
			AWSArn:       awsArn,
			Username:     splitted[len(splitted)-1],
			AWSAccountID: "54565121117",
		},
		AwsS3Bucket: &AwsS3Bucket{
			Name:       "bheembucket",
			Visibility: VisibilityTypePrivate,
		},
		AwsS3StaticSite: &AwsS3StaticSite{
			Name:          "bheemstaticsite",
			Visibility:    VisibilityTypePrivate,
			Website:       "website",
			LogBucketName: "bheembucketlog",
			IndexDocument: "index.html",
			ErrorDocument: "",
		},
		BackendData: &BackendData{
			Username: "postgres",
			Password: "PUXYfakq3r5es6NwNfMG",
			Host:     "tiny-postgres-tf-backend.crwimw7tbng8.ap-south-1.rds.amazonaws.com",
		},
		Organization: &Organization{
			Name: "tinybitt",
		},
		RefVersion: "v0.3.1",
	}
}

func main() {
	InitZap()
	conf := getConfig()

	// tml, err := template.ParseGlob("infrastructure/account-non-prod/qa/us-east-1/*.hcl")
	// if err != nil {
	// 	fmt.Printf("Could not parse glob")
	// 	return
	// }
	// fmt.Printf("%v", tml)
	// return

	for _, module := range []string{
		"infrastructure/account",
	} {
		data, err := ParseNestedFiles(module, conf)
		if err != nil {
			return
		}
		zap.S().Info(data)
		for fileName, fileVal := range data {
			fileName = replaceEnvironmentAndRegion(filepath.Join("parsedtiny", fileName), conf.Environment)
			zap.S().Infof("writing file %s", fileName)
			err = os.MkdirAll(getFolderPath(fileName), os.ModePerm)
			if err != nil {
				zap.S().Errorf("Could not create nested folder %s", getFolderPath(fileName))
			}
			err = ioutil.WriteFile(fileName, []byte(fileVal), 0644)
			if err != nil {
				zap.S().Error("could not write", err)
			}

		}
		// zap.S().Infof("%v", data)
	}

}

var TfEnvironment = Environment{
	Name:   "tfEnvironment",
	Region: "tfRegion",
}

func replaceEnvironmentAndRegion(f string, env *Environment) string {
	f = strings.ReplaceAll(f, TfEnvironment.Name, env.Name)
	f = strings.ReplaceAll(f, TfEnvironment.Region, env.Region)
	return f
}

func getFolderPath(f string) string {
	s := strings.Split(f, "/")
	return strings.Join(s[0:len(s)-1], "/")
}

//initZap : initialize zap suger logger
func InitZap() {
	var logger *zap.Logger
	var err error

	config := zap.NewDevelopmentConfig()
	config.EncoderConfig.EncodeLevel = zapcore.CapitalColorLevelEncoder
	logger, err = config.Build()

	logger.Info("Mode variable is set to development. Running zap in dev")

	if err != nil {
		log.Println("Failed to initialize Zap")
	}

	zap.ReplaceGlobals(logger)
	defer logger.Sync() // flushes buffer, if any

	zap.S().Info("Zap started")
}

func ParseNestedFiles(dir string, out interface{}) (map[string]string, error) {
	files, err := recurseThroughDir(dir)
	if err != nil {
		panic("Could not list all files")
	}
	data := make(map[string]string)
	for _, f := range files {
		tpl, err := template.ParseFiles(f)
		zap.S().Info("files", files)

		if err != nil {
			zap.S().Errorf("failed to read file %s. Err %+v", f, err)
			return nil, err
		}

		buf := &bytes.Buffer{}

		err = tpl.ExecuteTemplate(buf, getBaseName(f), out)
		if err != nil {
			zap.S().Infof("failed to execute template %s. Err %+v", f, err)
			return nil, err
		}
		data[f] = buf.String()

	}
	return data, nil
}
func getBaseName(f string) string {
	s := strings.Split(f, "/")
	return s[len(s)-1]
}

func recurseThroughDir(base string) ([]string, error) {
	files := []string{}
	fss, err := ioutil.ReadDir(base)
	if err != nil {
		return files, err
	}
	for _, fs := range fss {
		fullName := filepath.Join(base, fs.Name())
		if fs.IsDir() {
			out, err := recurseThroughDir(fullName)
			if err != nil {
				return files, err
			}
			files = append(files, out...)
		} else {
			files = append(files, fullName)
		}
	}
	return files, nil

}
