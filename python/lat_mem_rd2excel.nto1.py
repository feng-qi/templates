import datetime
import os
import sys
import xlsxwriter

def preprocess_lat_mem_rd_file(lat_mem_rd_results, save_every=1):
    data = []
    strides = []
    for file in lat_mem_rd_results:
        with open(file, 'r') as f_in:
            lines = f_in.readlines()
            stride = lines[0][1:].strip()
            strides.append(stride)
            file_data = [(float(line.split()[0]), float(line.split()[1]))
                for i, line in enumerate(lines[1:]) if i % save_every == 0 and line.strip()]
            data.append(file_data)

    if len(set(strides)) != 1:
        raise Exception("Strides in input files are not the same: " + str(strides))

    return data, strides[0]

# Insert data from different file into one worksheet with one empty column in between to separate them.
# Also add line chart at the top, with one line for each file.
def lat_mem_rd2excel(lat_mem_rd_results):
    data, stride = preprocess_lat_mem_rd_file(lat_mem_rd_results, save_every=1)

    workbook_name =  f'{lat_mem_rd_results[0]}.{len(lat_mem_rd_results)}in1.xlsx'
    worksheet_name = 'Sheet1'
    workbook = xlsxwriter.Workbook(workbook_name)
    worksheet = workbook.add_worksheet(worksheet_name)

    start_row = 30  # Variable to define the starting row for data insertion
    start_col = 0
    custom_labels = []
    block_size_show_label = {0.02344, 0.375, 32}

    # Read in the data and write it out to the excel file starting from row 20
    for file_idx, file_data in enumerate(data):
        labels = []
        worksheet.write(start_row - 1, start_col, lat_mem_rd_results[file_idx])
        for i, (block_size, latency) in enumerate(file_data):
            worksheet.write(i + start_row, start_col, block_size)
            worksheet.write(i + start_row, start_col + 1, latency)
            if block_size in block_size_show_label:
                labels.append({'value': latency})
            else:
                labels.append({'delete': True})
        custom_labels.append(labels)
        start_col += 3

    # Add a line chart at the top
    # For a scatter chart, the x axis will not be evenly distributed.
    # chart = workbook.add_chart({'type': 'scatter', "subtype": "smooth_with_markers"})
    # chart = workbook.add_chart({'type': 'scatter', "subtype": "smooth"})
    chart = workbook.add_chart({'type': 'line'})
    for i, file_data in enumerate(data):
        chart.add_series({
            'name': os.path.basename(lat_mem_rd_results[i]),
            'categories': [worksheet_name, start_row, i*3, len(file_data) - 1 + start_row, i*3],
            'values': [worksheet_name, start_row, i*3 + 1, len(file_data) - 1 + start_row, i*3 + 1],
            # 'data_labels': {'value': True, 'custom': custom_labels[i], 'position': 'above', 'leader_lines': True},
            # 'marker': {'type': 'circle', 'size': 1},
            'line': {'width': 1},
        })
    chart.set_x_axis({
        'name': 'Data Block Size (MB)',
    })
    chart.set_y_axis({
        'name': 'Latency (ns)',
    })
    chart.set_title({'name': 'lat_mem_rd: ' + stride})
    chart.set_size({'width': 1200, 'height': 576})
    worksheet.insert_chart('A1', chart)

    workbook.close()

def usage():
    print(f"Usage: python {sys.argv[0]} <lat_mem_rd_result_file1> <lat_mem_rd_result_file2> ...")

if __name__ == '__main__':
    now = datetime.datetime.now()

    if len(sys.argv) < 2:
        usage()
        sys.exit(0)

    lat_mem_rd2excel(sys.argv[1:])
