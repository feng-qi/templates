import sys
import datetime
import xlsxwriter

multiload_csv_title = "Samples	, Byte/thd	, ChaseThds	, ChaseNS	, ChaseMibs	, ChDeviate	, LoadThds	, LdMaxMibs	, LdAvgMibs	, LdDeviate	, ChaseArg	, MemLdArg"
type_list = ("memset-libc", "stream-sum", "stream-copy", "stream-triad", "stream-triad-p")

# For different MemLdArg in type_list, extract ChaseNS, LdAvgMibs and LoadThds as list.
def multiload2data(multiload_result):
    data_dict = {t: [] for t in type_list}
    with open(multiload_result, 'r') as f:
        for line in f:
            columns = [col.strip() for col in line.strip().split(',')]
            if columns[0].isdigit():  # Only process data lines, not headers
                chase_ns = float(columns[3])  # ChaseNS column index
                ld_avg_mibs = float(columns[8])  # LdAvgMibs column index
                load_thds = int(columns[6])  # LoadThds column index
                mem_ld_arg = columns[11]  # MemLdArg column index
                if mem_ld_arg in type_list:
                    data_dict[mem_ld_arg].append([chase_ns, ld_avg_mibs, load_thds])
    return data_dict

# Save return data of multiload2data to excel.
# For differnt type in type_list, each type has two columns, one for ChaseNS and one for LdAvgMibs.
# For different MemLdArg in type_list, each MemLdArg has two columns, one for ChaseNS and one for LdAvgMibs.
# Insert scatter diagrams for each MemLdArg, LdAvgMibs as x axis, ChaseNS as y axis.
def multiload2excel(multiload_result, filename):
    data_dict = multiload2data(multiload_result)
    worksheet_name = 'Sheet1'
    workbook = xlsxwriter.Workbook(filename)
    worksheet = workbook.add_worksheet(worksheet_name)
    col = 0
    start_row = 20
    for mem_ld_arg in type_list:
        worksheet.write(start_row, col, mem_ld_arg)
        worksheet.write(start_row + 1, col, "LoadThds")
        worksheet.write(start_row + 1, col + 1, "ChaseNS")
        worksheet.write(start_row + 1, col + 2, "LdAvgMibs")
        for row, (chase_ns, ld_avg_mibs, load_thds) in enumerate(data_dict[mem_ld_arg], start_row + 2):
            worksheet.write(row, col, load_thds)
            worksheet.write(row, col + 1, chase_ns)
            worksheet.write(row, col + 2, ld_avg_mibs)
        col += 3

    # Insert scatter diagrams
    abc = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    x_col = 2
    y_col = 1
    for idx, mem_ld_arg in enumerate(type_list):
        scatter_chart = workbook.add_chart({"type": "scatter", "subtype": "smooth_with_markers"})
        scatter_chart.set_title({'name': mem_ld_arg})
        scatter_chart.add_series({
            'name': mem_ld_arg,
            # 'categories': f"='Multiload Data'!${abc[x_col]}${start_row + 3}:${abc[x_col]}${start_row + 2 + len(data_dict[mem_ld_arg])}",
            # 'values': f"='Multiload Data'!${abc[y_col]}${start_row + 3}:${abc[y_col]}${start_row + 2 + len(data_dict[mem_ld_arg])}",
            'categories': [worksheet_name, start_row + 2, x_col, start_row + 1 + len(data_dict[mem_ld_arg]), x_col],
            'values': [worksheet_name, start_row + 2, y_col, start_row + 1 + len(data_dict[mem_ld_arg]), y_col],
            'marker': {'type': 'circle', 'size': 4},
            'line': {'width': 1},
        })
        worksheet.insert_chart(chart=scatter_chart, row=0, col=idx*8)
        x_col += 3
        y_col += 3

    workbook.close()

def usage():
    print(f"Usage: python {sys.argv[0]} <multiload_result_file1> <multiload_result_file2> ...")

if __name__ == '__main__':
    now = datetime.datetime.now()

    if len(sys.argv) < 2:
        usage()
        sys.exit(0)

    for multiload_result in sys.argv[1:]:
        multiload_xlsx = multiload_result + ".xlsx"
        multiload2excel(multiload_result, multiload_xlsx)
