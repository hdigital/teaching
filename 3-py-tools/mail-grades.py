import os, shutil
import numpy as np
import pandas as pd
from jinja2 import Template


email_dir = 'z-Mail-Note'

if os.path.exists(email_dir):
    shutil.rmtree(email_dir)
os.makedirs(email_dir)


with open('mail-grades-template.txt') as f:
    mail_template = f.read()

noten = (pd.read_excel("0-Studierende-Leistungen.xlsx")
            .replace({np.nan: None})
            .dropna(subset = ["Studierender"])
            .to_dict(orient = "records")
        )

for note in noten:
    template = Template(mail_template, trim_blocks=True)
    email_path = os.path.join(email_dir, f"{note['Studierender'].lower().replace(' ', '-')}.txt")
    with open(email_path, "w") as f:
        f.write(template.render(note))
