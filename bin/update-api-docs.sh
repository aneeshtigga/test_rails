#!/bin/zsh

# Clean up old artifacts (if they exist)
if [ -f openapi-temp.yaml ]; then
    rm openapi-temp.yaml
fi

if [ -f api-docs.json ]; then
    rm api-docs.json
fi

# Gets the current branch name from the git client
CURRENT_BRANCH=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
OPENAPI_VERSION=$CURRENT_BRANCH
S3_UPLOAD_PATH="s3://lifestance-web-openapi/$CURRENT_BRANCH/api-docs.json"

case $CURRENT_BRANCH in
  dev | qa)
    ;;
  main)
    echo " "
    echo "What is the release version?"
    read OPENAPI_VERSION
    S3_UPLOAD_PATH="s3://lifestance-web-openapi/prod/api-docs.json"
    ;;
  *)
    if [[ $CURRENT_BRANCH =~ 'RC' ]];
    then 
      S3_UPLOAD_PATH="s3://lifestance-web-openapi/rc/api-docs.json"
    else
      echo 'No-op.  Not on a currently openapi documented branch.';
      exit 0;
    fi
    ;;
esac

echo " "
echo "Generating API docs for $CURRENT_BRANCH..."
echo "Openapi version is $OPENAPI_VERSION"
echo "s3 bucket is $S3_UPLOAD_PATH"
appmap openapi >> openapi-temp.yaml
echo " "
echo "API docs generated.  Converting yaml to json..."
echo " "
ruby -ryaml -rjson -e 'puts JSON.pretty_generate(YAML.load(STDIN))' < openapi-temp.yaml >> api-docs.json
yq -iP '.info.title="polaris"' api-docs.json -o json
yqBranchValue="${OPENAPI_VERSION}" yq -iP '.info.version=env(yqBranchValue)' api-docs.json -o json
echo " "
echo "Conversion complete, uploading to s3..."
aws s3 cp api-docs.json $S3_UPLOAD_PATH
echo " "
echo "Upload complete.  Cleaning up..."

if [ -f openapi-temp.yaml ]; then
    rm openapi-temp.yaml
fi

if [ -f api-docs.json ]; then
    rm api-docs.json
fi

echo " "
echo "Done!"
