import streamlit as st
from PIL import Image
import pytesseract
from pdf2image import convert_from_bytes
from datetime import datetime
import re

st.set_page_config(page_title="Arbeitszeit-Differenz Rechner")

st.title("Arbeitszeit-Differenz Rechner 📊")

uploaded_file1 = st.file_uploader("Erstes Bild/PDF hochladen", type=['png','jpg','jpeg','pdf'])
uploaded_file2 = st.file_uploader("Zweites Bild/PDF hochladen", type=['png','jpg','jpeg','pdf'])

def extract_text(file):
    if file.name.endswith('.pdf'):
        images = convert_from_bytes(file.read())
        text = ""
        for img in images:
            text += pytesseract.image_to_string(img)
        return text
    else:
        img = Image.open(file)
        return pytesseract.image_to_string(img)

def calculate_diff(text1, text2):
    # Muster: 08:00-12:00
    pattern = r'(\d{1,2}:\d{2})\s*[-–]\s*(\d{1,2}:\d{2})'
    times1 = re.findall(pattern, text1)
    times2 = re.findall(pattern, text2)
    
    def total_minutes(times):
        total = 0
        for start, end in times:
            fmt = "%H:%M"
            start_dt = datetime.strptime(start, fmt)
            end_dt = datetime.strptime(end, fmt)
            total += (end_dt - start_dt).seconds // 60
        return total
    
    diff = total_minutes(times2) - total_minutes(times1)
    hours = diff // 60
    minutes = diff % 60
    return hours, minutes

if uploaded_file1 and uploaded_file2:
    text1 = extract_text(uploaded_file1)
    text2 = extract_text(uploaded_file2)
    hours, minutes = calculate_diff(text1, text2)
    st.success(f"Differenz: {hours} Stunden und {minutes} Minuten")
else:
    st.info("Bitte lade beide Dateien hoch, um die Differenz zu berechnen.")
