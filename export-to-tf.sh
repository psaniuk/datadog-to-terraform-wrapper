RESOURCE_TYPE=$1
RESOURCE=$2
DD_API_KEY=$3
DD_APP_KEY=$4

if [ "$RESOURCE_TYPE" == "" ]; then
    echo "Specify DataDog resource type as the first argument. For example: dashboard, monitor."
    exit 1
fi

if [ "$RESOURCE" == "" ]; then
    echo "Specify resource id as the second argument. It can be taken from the exporting resource URL."
    exit 1
fi

if [ "$DD_API_KEY" == "" ]; then
    DD_API_KEY=$(gopass show --force apm-admin/app.datadoghq.com/Terraform-API-Key)
    if [ "$DD_API_KEY" == "" ]; then
        echo "Specify DataDog API key as the third argument or request the access to gopass apm-admin folder."
        exit 1
    fi
fi

if [ "$DD_APP_KEY" == "" ]; then
    DD_APP_KEY=$(gopass show --force apm-admin/app.datadoghq.com/Terraform-APP-Key)
     if [ "$DD_APP_KEY" == "" ]; then
        echo "Specify DataDog APP key as the fourth argument or request the access to gopass apm-admin folder."
        exit 1
    fi
fi

docker inspect --format=" " dd-to-tf-exporter
if [ $? -eq 0 ];
then
     echo "The Docker image dd-to-tf-exporter already exists."
else
     echo "Building Docker image with terraformer..."   
     docker build -t dd-to-tf-exporter .
fi

echo "Exporting resource..."

docker run \
-v $(pwd):/opt dd-to-tf-exporter \
--resources=$RESOURCE_TYPE \
--filter=$RESOURCE_TYPE=$RESOURCE \
--api-key=$DD_API_KEY \
--app-key=$DD_APP_KEY -o "/opt" 
