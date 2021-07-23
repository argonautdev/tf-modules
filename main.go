package main

import (
	"bytes"
	"fmt"
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
	Name string
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
	Environment     Environment
	Cluster         Cluster
	NodeGroup       NodeGroup
	RDS             RDS
	AWS             AWS
	AwsS3Bucket     AwsS3Bucket
	AwsS3StaticSite AwsS3StaticSite
	BackendData     BackendData
	Organization    Organization
	RefVersion      string
}

func main() {
	InitZap()
	awsArn := "arn:aws:iam::054565121117:user/surya"
	splitted := strings.Split(awsArn, "/")
	conf := Config{
		Environment{
			Name: "ligma",
		},
		Cluster{
			Name: "ligma",
		},
		NodeGroup{
			Name:                "ligma",
			InstanceType:        "t3.medium",
			Spot:                true,
			AutoScale:           false,
			NumberOfInstance:    3,
			NumberOfInstanceMax: 3,
			NumberOfInstanceMin: 1,
			DiskSize:            20,
		},
		RDS{
			Name:          "ligmapostgres",
			Visibility:    VisibilityTypePrivate,
			Identifier:    "ligmapostgres",
			Engine:        "postgres",
			EngineVersion: "11.10",
			InstanceClass: "db.t3.micro",
			Storage:       10,
			Username:      "admin",
			Password:      "admin",
		},
		AWS{
			AWSArn:       awsArn,
			Username:     splitted[len(splitted)-1],
			AWSAccountID: "54565121117",
		},
		AwsS3Bucket{
			Name:       "ligmabucket",
			Visibility: VisibilityTypePrivate,
		},
		AwsS3StaticSite{
			Name:          "ligmastaticsite",
			Visibility:    VisibilityTypePrivate,
			Website:       "website",
			LogBucketName: "ligmabucketlog",
			IndexDocument: "index.html",
			ErrorDocument: "",
		},
		BackendData{
			Username: "argonaut",
			Password: "VPnoVfCdNQiJypbRaSUjisFNHmEKonal",
			Host:     "tf-orgs.cmdfavrazybz.us-east-2.rds.amazonaws.com",
		},
		Organization{
			Name: "argonaut",
		},
		"pr-pure-modules",
	}
	// tml, err := template.ParseGlob("infrastructure/account-non-prod/qa/us-east-1/*.hcl")
	// if err != nil {
	// 	fmt.Printf("Could not parse glob")
	// 	return
	// }
	// fmt.Printf("%v", tml)
	// return

	for _, module := range []string{
		"infrastructure/account-non-prod/qa",
	} {
		location := fmt.Sprintf("%s", module)
		data, err := ParseNestedFiles(location, &conf)
		if err != nil {
			return
		}
		zap.S().Info(data)
		for fileName, fileVal := range data {
			zap.S().Infof("writing file %s", fileName)
			fileName = filepath.Join("parsed", fileName)
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

func getFolderPath(f string) string {
	s := strings.Split(f, "/")
	return strings.Join(s[0:len(s)-1], "/")
}
func ExtractConfig(folderPath string, values interface{}) (map[string]string, error) {

	data := make(map[string]string)
	fp := fmt.Sprintf("%s/*.hcl", folderPath)
	var files []string
	tpl, err := template.ParseGlob(fp)
	if err != nil {
		zap.S().Infof("failed to parse %s: %s", fp, err)
		return nil, err
	}

	err = filepath.Walk(folderPath, func(path string, info os.FileInfo, err error) error {
		if !info.IsDir() {
			files = append(files, filepath.Base(path))
		}
		return nil
	})
	if err != nil {
		zap.S().Errorf("Could not walk folder. Err: %v", err)
		return nil, err
	}

	zap.S().Info("files", files)

	if err != nil {
		zap.S().Errorf("failed to read file names inside folder %s: %s", folderPath, err)
		return nil, err
	}

	for _, val := range files {
		buf := &bytes.Buffer{}

		err = tpl.ExecuteTemplate(buf, val, values)
		if err != nil {
			zap.S().Infof("failed to execute template %s: %s", val, err)
			return nil, err
		}

		nameAndExtension := strings.Split(val, ".")
		// if the extension is tpl replace with tf
		if len(nameAndExtension) > 0 && nameAndExtension[len(nameAndExtension)-1] == "tpl" {
			nameAndExtension[len(nameAndExtension)-1] = "tf"
		}
		file := strings.Join(nameAndExtension, ".")
		data[filepath.Base(file)] = buf.String()
	}
	return data, nil
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
