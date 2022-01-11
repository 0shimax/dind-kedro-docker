1. `kedro new` and `cd {project_name}` and `kedro docker init`
2. Add `!data/01_raw/.gitkeep` into `{project_name}/.dockerignore`.
3. Add lines into `{project_name}/src/requirements.txt` as follows.
```
pandas~=1.3.5
pandas-gbq~=0.16.0
scipy~=1.7.3
numpy~=1.21.0
scikit-learn~=1.0.2
Pillow~=9.0.0
gcsfs~=2021.11.1
kedro-kubeflow~=0.4.7
google-cloud-scheduler~=2.5.0
google-cloud-aiplatform~=1.9.0
```

4. Create a python file like the following under a certain dir (e.g. {project_name}/vertex_pipeline/run_kedro_kubeflow.py).
```
import subprocess
import logging

log = logging.getLogger(__name__)

compiled_file_path = "/home/kedro/kedro-vertex-pipeline.json"
res = subprocess.run(["kedro", "kubeflow", "-e", "base", "compile", "-o", compiled_file_path], capture_output=True)

with open(compiled_file_path, "r") as f:
    for s_line in f:
        print(s_line)
```

5. Create shell script for creating a compiled Vertex Pipeline spec file under a certain dir (e.g. {project_name}/vertex_pipeline/compile_vertes_pipeline_spec.sh).
```
sudo touch ./vertex_pipeline/kedro-vertex--pipeline.json
sudo touch ./vertex_pipeline/kedro-vertex-pipeline.json
sudo chmod a+rwx ./vertex_pipeline/*.json
sudo kedro docker cmd python3 /home/kedro/vertex_pipeline/run_kedro_kubeflow.py > ./vertex_pipeline/kedro-vertex--pipeline.json && sudo tail -n+3 ./vertex_pipeline/kedro-vertex--pipeline.json > ./vertex_pipeline/kedro-vertex-pipeline.json
sudo rm -rf ./vertex_pipeline/kedro-vertex--pipeline.json
```

6. `kedro docker build --docker-args="--no-cache" --base-image="google/cloud-sdk:latest"`
7. `bash ./vertex_pipeline/compile_vertes_pipeline_spec.sh`