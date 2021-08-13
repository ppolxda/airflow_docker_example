# For more information, please refer to https://aka.ms/vscode-docker-python
FROM apache/airflow:latest-python3.8
#  my-awesome-apt-dependency-to-add \
# USER root
# COPY scripts/sources.list  /etc/apt/sources.list
# RUN apt-get update && apt-get install -y iputils-ping
# RUN apt-get update \
#     && apt-get install -y --no-install-recommends \
#     build-essential \
#     && apt-get autoremove -yqq --purge \
#     && apt-get clean \
#     && rm -rf /var/lib/apt/lists/*
# USER airflow

EXPOSE 8080

# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1

ENV PYPI_TRUSTED=mirrors.aliyun.com
ENV PYPI_URL=http://mirrors.aliyun.com/pypi/simple
ENV POETRY_VERSION=1.1.7

ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"
ENV REQUIREMENTS_PATH=./requirements.txt

ENV AIRFLOW_UID=1000
ENV AIRFLOW_GID=0


# WORKDIR /opt/airflow/dags
# COPY depends /app/depends
COPY pyproject.toml ./pyproject.toml
COPY poetry.lock ./poetry.lock
COPY ./depands /depands
COPY ./dags /opt/airflow/dags
COPY ./plugins /opt/airflow/plugins

RUN poetry export -f requirements.txt --output ${REQUIREMENTS_PATH} --without-hashes
RUN python -m pip install --user --trusted-host ${PYPI_TRUSTED} -r ${REQUIREMENTS_PATH}

# Install pip requirements
# COPY requirements.dev.txt ./requirements.txt
# RUN python -m pip install -r requirements.txt
# RUN pip install WTForms -i http://192.168.186.125:8081/repository/pypi/simple
# RUN pip install apache-airflow[postgres,redis]==2.0.0 -U -i http://192.168.186.125:8081/repository/pypi/simple
# RUN ping 192.168.186.125 -c 5
RUN python -m pip install -r /opt/airflow/dags/requirements.txt
# RUN python -m pip install /depands/tr -i http://192.168.186.125:8081/repository/pypi/simple

# Switching to a non-root user, please refer to https://aka.ms/vscode-docker-python-user-rights
# RUN useradd appuser && chown -R appuser /app
# USER appuser

# During debugging, this entry point will be overridden. 
# For more information, please refer to https://aka.ms/vscode-docker-python-debug
# ENV AIRFLOW_USER_HOME_DIR ./airflow
# CMD ["airflow", "webserver"]
