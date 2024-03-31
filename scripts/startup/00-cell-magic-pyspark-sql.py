"""Custom cell magic for Spark SQL.

"""
from IPython.core.magic import register_line_cell_magic
from pyspark.sql import DataFrame


@register_line_cell_magic
def sql(line, cell=None) -> DataFrame | None:
    """Return a Spark DataFrame for lazy evaluation of the sql. Use: %sql or %%sql"""
    val = cell if cell is not None else line

    response = spark.sql(val)

    return response if isinstance(response, DataFrame) else None


@register_line_cell_magic
def sql_display(line, cell=None) -> DataFrame | None:
    """Return a Spark DataFrame for lazy evaluation of the sql. Use: %sql or %%sql"""
    val = cell if cell is not None else line 

    response = spark.sql(val)

    return response.toPandas() if isinstance(response, DataFrame) else None
