#!/bin/bash

# npm install openapi-typescript-codegen -g
# npm install @openapitools/openapi-generator-cli -g
# openapi-generator-cli version-manager set 6.0.1
# install java runtime

remove_trailing_slash() {
  local path="$1"
  echo "${path%/}"
}

if [[ -z $1 ]]; then
	echo "Please provide the path to keep the generated sdk in"
	echo "If you want to release for js. Run ./script ../arg/api --release-js"
	exit 1
fi

if [[ ($# -le 1) ]]; then
	echo "put --release-js or --release-go as second parameter to release"
fi

if [[ ($# -ge 2) && ("$2" == "--release-js") ]]; then
	api_path=$(remove_trailing_slash $1)
	echo "Generating sdk"
	latest_version=$(openapi-generator-cli version)
	openapi-generator-cli version-manager set 5.2.1	
	echo "Generating sdk using typescript-axios and schemas"
	openapi-generator-cli generate -i docs/swagger.json \
		-g typescript-axios \
		-o $api_path \
		--additional-properties=supportsES6=true \
		--additional-properties=typescriptThreePlus=true \
		--additional-properties=useSingleRequestParameter=true \
		--additional-properties=withSeparateModelsAndApi=true,modelPackage=models,apiPackage=api,npmName=@argonautdev/midgard-js-sdk,npmVersion=$1,legacyDiscriminatorBehavior=false,disallowAdditionalPropertiesIfNotPresent=false \
		--enable-post-process-file \
		--skip-validate-spec

	echo "Removing existing 'schemas' directory"
	rm -rf $api_path/schemas
	echo "Removed existing 'schemas' directory"

	openapi -i docs/swagger.json \
		-o $api_path/typescript-fetch \
		--exportCore false \
		--exportServices false \
		--exportModels false \
		--exportSchemas true

	mv $api_path/typescript-fetch/schemas $api_path/schemas
	mv $api_path/typescript-fetch/index.ts $api_path/schema.ts
	echo 'import * as Schema from "./schema";' >> $api_path/index.ts
	echo -e "\nexport {Schema};" >> $api_path/index.ts
	rmdir $api_path/typescript-fetch
	rm $api_path/package.json
	rm $api_path/tsconfig.json
	rm $api_path/git_push.sh
	rm $api_path/README.md
	rm $api_path/.gitignore
	rm $api_path/.npmignore

fi 