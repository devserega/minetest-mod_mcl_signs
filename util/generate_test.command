#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Double click to execute bash script.

import os
import sys
import subprocess

# Проверяем, находимся ли мы в виртуальном окружении
IN_VENV = sys.prefix != sys.base_prefix

# Путь к папке скрипта
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

# Путь к виртуальному окружению
VENV_PATH = os.path.join(SCRIPT_DIR, "venv")

# Если не в виртуальном окружении, создаем его и перезапускаем скрипт в нем
if not IN_VENV:
    print("🔹 Проверка окружения...")

    # Если venv не существует, создаём его
    if not os.path.exists(VENV_PATH):
        print("🔹 Виртуальное окружение не найдено. Создаю venv...")
        subprocess.run([sys.executable, "-m", "venv", VENV_PATH])

    # Выбираем правильный Python внутри venv
    PYTHON_EXEC = os.path.join(VENV_PATH, "bin", "python3")  # В Linux или macOS

    # Устанавливаем зависимости
    print("🔹 Устанавливаю необходимые пакеты...")
    subprocess.run([f"{PYTHON_EXEC}", "-m", "pip", "install", "--quiet", "pillow"])

    # Перезапускаем скрипт в venv
    print("🔹 Перезапускаю скрипт в виртуальном окружении...")
    
    # Перезапуск через subprocess с экранированным путём
    subprocess.run([PYTHON_EXEC] + sys.argv)

    # Прекращаем выполнение текущего скрипта
    sys.exit()

from PIL import Image, ImageDraw, ImageFont, ImageFilter

FONT_NAME = "NotoSans-Regular.ttf" # Arial Bold.ttf
FONT_SIZE = 10 # 9 10
IMG_WIDTH = 800
IMG_HEIGHT = 12
FONT_PATH = os.path.join(SCRIPT_DIR, "fonts", FONT_NAME)

#im = Image.new("RGB", (IMG_WIDTH, IMG_HEIGHT))
img = Image.new("L", (IMG_WIDTH, IMG_HEIGHT), 255)  # "L" = 8-бит серый (фон черный)

draw = ImageDraw.Draw(img)

# use a truetype font
font = ImageFont.truetype(FONT_PATH, FONT_SIZE)

text = "ABCDEFGHIJKLMNOPQRSTUVWXY gqhp Привіт як справи 999. Дракон Смауг живе тут.□"
draw.text((0, 0), text, font=font, fill=0)

# remove unneccessory whitespaces if needed
#im=im.crop(im.getbbox())

# Применяем фильтр для уменьшения толщины букв
#img = img.filter(ImageFilter.FIND_EDGES)

# Преобразуем изображение в LA (grayscale + альфа-канал)
img_la = img.convert("LA")

# write into file
img_la.save(os.path.join(SCRIPT_DIR, "img.png"))