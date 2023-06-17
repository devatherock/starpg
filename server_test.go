package main

import (
	"bytes"
	"encoding/json"
	"io"
	"net/http"
	"os"
	"testing"

	jsoniter "github.com/json-iterator/go"
	"github.com/stretchr/testify/assert"
)

const baseUrl string = "http://localhost:8082"

func TestExpandTemplate(test *testing.T) {
	context := map[string]interface{}{
		"vars": map[string]string{
			"image": "go:1.14",
		},
	}
	contextJson, _ := jsoniter.Marshal(context)

	template, _ := os.ReadFile("test/testdata/input_starlark_template.py")
	requestBody := string(template) + "\nctx = " + string(contextJson) + "\nprint(main(ctx))"
	request, _ := http.NewRequest("POST", baseUrl+"/exec", bytes.NewBuffer([]byte(requestBody)))

	client := &http.Client{}
	response, err := client.Do(request)
	assert.Nil(test, err)

	defer response.Body.Close()

	assert.Equal(test, 200, response.StatusCode)

	responseBody, err := io.ReadAll(response.Body)
	assert.Nil(test, err)

	jsonResponse := make(map[string]interface{})
	json.Unmarshal(responseBody, &jsonResponse)
	assert.Equal(test, 2, len(jsonResponse))
	assert.Equal(test, "1", jsonResponse["version"])

	steps := jsonResponse["steps"].([]interface{})
	step := steps[0].(map[string]interface{})
	commands := step["commands"].([]interface{})

	assert.Equal(test, 1, len(steps))
	assert.Equal(test, 3, len(step))
	assert.Equal(test, 2, len(commands))
	assert.Equal(test, "build", step["name"])
	assert.Equal(test, "go:1.14", step["image"])
	assert.Equal(test, "go build", commands[0])
	assert.Equal(test, "go test", commands[1])
}
