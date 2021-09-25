import glob
from PyPDF2 import PdfFileMerger, PdfFileReader

folder_pdfs = "Lerntagebuch-Kopie/*.pdf"
grading_sheet_pdf = "Schema-Bewertung-HD.pdf"

for file_name in sorted(glob.glob(folder_pdfs)):
    print(file_name)
    merger = PdfFileMerger()

    merger.append(PdfFileReader(file_name))
    merger.append(PdfFileReader(grading_sheet_pdf))

    merger.write(file_name)
