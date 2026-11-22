"""Python data-processing functions adapted from IS4S761 assessed coursework.

Logic is retained from the original submitted source. Instructor-provided
assignment comments were removed to avoid republishing teaching materials.
"""

def load_data_from_file_into_2D_list(filename: str) -> list:
    data_table = []
    sublist = []
    with open(filename) as file:
        file_contents = file.readlines()
    for line in file_contents:
        if line.startswith('END'):
            if len(sublist) > 0:
                data_table.append(sublist)
            break
        elif line.startswith('COLUMN'):
            column_name = ' '.join(line.strip().split(' ')[1:])
            if len(sublist) > 0:
                data_table.append(sublist)
            sublist = [column_name]
        else:
            sublist.append(line.strip())
    return data_table

def load_data_from_file_into_dictionary(filename: str) -> dict:
    data_table = {}
    data = []
    column_name = ''
    with open(filename) as file:
        for line in file:
            if line.startswith('COLUMN'):
                if len(data) > 0:
                    data_table[column_name] = data
                    data = []
                column_name = ' '.join(line.split(' ')[1:]).strip()
            elif line[:3] == 'END':
                if len(data) > 0:
                    data_table[column_name] = data
                    break
            else:
                data.append(line.strip())
    return data_table

def return_sublist_from_either_dictionary_or_2D_list(data_table: list | dict, key: str) -> list:
    if not isinstance(data_table, (list, dict)):
        return None
    if isinstance(data_table, dict):
        if key not in data_table:
            return None
        return data_table[key]
    if isinstance(data_table, list):
        for row in data_table:
            if not isinstance(row, list) or len(row) == 0:
                continue
            if row[0] == key:
                return row[1:]
        return None
    return None

def return_sublist_total_from_either_dictionary_or_2D_list(data_table: list | dict, key: str) -> float | None:
    if not isinstance(data_table, (list, dict)):
        return None
    values = return_sublist_from_either_dictionary_or_2D_list(data_table, key)
    if values is None:
        return None
    if len(values) == 0:
        return None
    total = 0.0
    for item in values:
        try:
            number = float(item)
        except ValueError:
            return None
        total = total + number
    return total

def return_sublist_mean_from_either_dictionary_or_2D_list(data_table: list | dict, key: str) -> float | None:
    if not isinstance(data_table, (list, dict)):
        return None
    values = return_sublist_from_either_dictionary_or_2D_list(data_table, key)
    if values is None:
        return None
    if len(values) == 0:
        return None
    total = return_sublist_total_from_either_dictionary_or_2D_list(data_table, key)
    if total is None:
        return None
    mean = total / len(values)
    return mean

def return_sublist_median_from_either_dictionary_or_2D_list(data_table: list | dict, key: str) -> float | None:
    if not isinstance(data_table, (list, dict)):
        return None
    values = return_sublist_from_either_dictionary_or_2D_list(data_table, key)
    if values is None:
        return None
    if len(values) == 0:
        return None
    numeric_values = []
    for item in values:
        try:
            number = float(item)
        except ValueError:
            return None
        numeric_values.append(number)
    n = len(numeric_values)
    for i in range(n - 1):
        for j in range(i + 1, n):
            if numeric_values[j] < numeric_values[i]:
                temp = numeric_values[i]
                numeric_values[i] = numeric_values[j]
                numeric_values[j] = temp
    n = len(numeric_values)
    middle_index = n // 2
    if n % 2 == 1:
        median = numeric_values[middle_index]
    else:
        median = (numeric_values[middle_index - 1] + numeric_values[middle_index]) / 2
    return median

def return_total_value_from_either_dictionary_or_2D_list(data_table: list) -> float | None:
    if not isinstance(data_table, (list, dict)):
        return None
    total = 0.0
    numeric_value_found = False
    if isinstance(data_table, dict):
        for key in data_table:
            sub_total = return_sublist_total_from_either_dictionary_or_2D_list(data_table, key)
            if sub_total is None:
                continue
            total = total + sub_total
            numeric_value_found = True
        if not numeric_value_found:
            return 0.0
        return total
    if isinstance(data_table, list):
        for row in data_table:
            if not isinstance(row, list) or len(row) == 0:
                continue
            column_name = row[0]
            sub_total = return_sublist_total_from_either_dictionary_or_2D_list(data_table, column_name)
            if sub_total is None:
                continue
            total = total + sub_total
            numeric_value_found = True
        if not numeric_value_found:
            return 0.0
        return total
    return None

def recursive_return_max_value_from_either_dictionary_or_2D_list(data_table: list | dict, key: str) -> float | None:
    if not isinstance(data_table, (list, dict)):
        return None
    values = return_sublist_from_either_dictionary_or_2D_list(data_table, key)
    if values is None:
        return None
    if len(values) == 0:
        return None
    numeric_values = []
    for item in values:
        try:
            number = float(item)
        except ValueError:
            return None
        numeric_values.append(number)

    def inner_recursive_max(index: int, current_max: float) -> float:
        if index == len(numeric_values):
            return current_max
        if numeric_values[index] > current_max:
            current_max = numeric_values[index]
        return inner_recursive_max(index + 1, current_max)
    first_value = numeric_values[0]
    max_value = inner_recursive_max(1, first_value)
    return max_value
