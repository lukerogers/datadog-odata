FROM mcr.microsoft.com/dotnet/aspnet:7.0-alpine

RUN apk add curl

RUN mkdir -p /opt/datadog \
    && mkdir -p /var/log/datadog \
    && TRACER_VERSION=$(curl -s https://api.github.com/repos/DataDog/dd-trace-dotnet/releases/latest | grep tag_name | cut -d '"' -f 4 | cut -c2-) \
    && curl -LO https://github.com/DataDog/dd-trace-dotnet/releases/download/v${TRACER_VERSION}/datadog-dotnet-apm-${TRACER_VERSION}-musl.tar.gz \
    && tar -C /opt/datadog -xzf datadog-dotnet-apm-${TRACER_VERSION}-musl.tar.gz \
    && sh /opt/datadog/createLogPath.sh \
    && rm ./datadog-dotnet-apm-${TRACER_VERSION}-musl.tar.gz

ENV CORECLR_ENABLE_PROFILING=1 \
 CORECLR_PROFILER={846F5F1C-F9AE-4B07-969E-05C26BC060D8} \
 CORECLR_PROFILER_PATH=/opt/datadog/Datadog.Trace.ClrProfiler.Native.so \
 DD_DOTNET_TRACER_HOME=/opt/datadog

WORKDIR /app

ENV DOTNET_RUNNING_IN_CONTAINER=true \
  ASPNETCORE_URLS=http://+:8080 \
  COMPlus_EnableDiagnostics=0

COPY publish/. /app

EXPOSE 8080

ENTRYPOINT [ "dotnet", "datadogodata.dll" ]