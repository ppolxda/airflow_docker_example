# import requests
from typing import List
from airflow.utils import dates
from airflow.models.dag import DAG
from airflow.utils.task_group import TaskGroup
from airflow.operators.dummy import DummyOperator


HTTP_TIMEOUT = 60
DAG_NAME = "test"
DAG_TG_NAME = "group_test"
DEFAULT_ARGS = {
    "owner": "airflow",
    # "start_date": dates.days_ago(2),
    "depends_on_past": False,
}


def task_group_id(user, subname):
    return "{}.{}_{}".format(DAG_TG_NAME, subname, user)


with DAG(
    DAG_NAME,
    default_args=DEFAULT_ARGS,
    start_date=dates.days_ago(1),
    schedule_interval="@once",
    # schedule_interval="*/30 * * * *",
    # schedule_interval="*/1 * * * *",
    catchup=False,
    tags=["tests"],
) as dag:
    dummy_start = DummyOperator(task_id="task_start", dag=dag)
    dummy_end = DummyOperator(task_id="task_end", dag=dag, trigger_rule="all_done")
    dummy_process = DummyOperator(task_id="doing", dag=dag)

    with TaskGroup(
        DAG_TG_NAME, tooltip="doing_group", prefix_group_id=False, dag=dag
    ) as req_section:
        for user in range(10):
            py_req = DummyOperator(
                task_id=task_group_id(user, "group_task_doing"),
                dag=dag,
            )

    dummy_reuslt = DummyOperator(
        task_id="reuslt",
        # python_callable=keep_results,
        trigger_rule="all_done",
        dag=dag,
    )

    dummy_start >> req_section >> dummy_reuslt >> dummy_end

if __name__ == "__main__":
    from airflow.utils.state import State

    dag.clear(dag_run_state=State.NONE)
    dag.run()
