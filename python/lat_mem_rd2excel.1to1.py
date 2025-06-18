import datetime
import os
import sys
import xlsxwriter

def preprocess_lat_mem_rd_file(lat_mem_rd_result, save_every=1):
    with open(lat_mem_rd_result, 'r') as f_in:
        lines = f_in.readlines()
        stride = lines[0][1:].strip()
        data = [(float(line.split()[0]), float(line.split()[1]))
            for i, line in enumerate(lines[1:]) if i % save_every == 0 and line.strip()]

    return data, stride

def lat_mem_rd2excel(lat_mem_rd_result, lat_mem_rd_xlsx):
    data, stride = preprocess_lat_mem_rd_file(lat_mem_rd_result, save_every=1)

    workbook = xlsxwriter.Workbook(lat_mem_rd_xlsx)
    worksheet_name = 'Sheet1'
    worksheet = workbook.add_worksheet(worksheet_name)

    start_row = 30  # Variable to define the starting row for data insertion
    custom_label = []
    block_size_show_label = {0.02344, 0.375, 32}

    # Read in the data and write it out to the excel file starting from row 20
    for i, (block_size, latency) in enumerate(data):
        worksheet.write(i + start_row, 0, block_size)
        worksheet.write(i + start_row, 1, latency)
        if block_size in block_size_show_label:
            custom_label.append({'value': latency})
        else:
            custom_label.append({'delete': True})

    # Add a line diagram at the top
    # chart = workbook.add_chart({'type': 'scatter', "subtype": "smooth_with_markers"})
    # chart = workbook.add_chart({'type': 'scatter', "subtype": "smooth"})
    chart = workbook.add_chart({'type': 'line'})
    chart.add_series({
        'name': os.path.basename(lat_mem_rd_result),
        'categories': [worksheet_name, start_row, 0, len(data) - 1 + start_row, 0],
        'values': [worksheet_name, start_row, 1, len(data) - 1 + start_row, 1],
        # 'data_labels': {'value': True, 'custom': custom_label, 'position': 'above', 'leader_lines': True},
        # 'marker': {'type': 'circle', 'size': 3},
        'line': {'width': 1},
    })
    chart.set_x_axis({
        'name': 'Data Block Size (MB)',
    })
    chart.set_y_axis({
        'name': 'Latency (ns)',
    })
    chart.set_title({'name': 'lat_mem_rd: ' + stride})
    chart.set_size({'width': 1000, 'height': 576})
    worksheet.insert_chart('A1', chart)

    workbook.close()

def usage():
    print(f"Usage: python {sys.argv[0]} <lat_mem_rd_result_file1> <lat_mem_rd_result_file2> ...")

if __name__ == '__main__':
    now = datetime.datetime.now()

    if len(sys.argv) < 2:
        usage()
        sys.exit(0)

    for lat_mem_rd_result in sys.argv[1:]:
        lat_mem_rd_xlsx = lat_mem_rd_result + ".xlsx"
        lat_mem_rd2excel(lat_mem_rd_result, lat_mem_rd_xlsx)
