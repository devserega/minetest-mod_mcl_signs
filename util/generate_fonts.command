#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Double click to execute bash script.

import os
import sys
import subprocess

# Настройки шрифта и изображения
FONT_NAME = "Arial Bold.ttf"
FONT_SIZE = 10 # 9 10
IMG_WIDTH = 9 # 6
IMG_HEIGHT = 12 # 12
MIN_CHAR_IMG_WIDTH = 5

# Путь к папке скрипта
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
#print("SCRIPT_DIR={0}".format(SCRIPT_DIR))

# Путь к шрифту (замени на свой)
FONT_PATH = os.path.join(SCRIPT_DIR, "fonts", FONT_NAME)

# Папка для сохранения текстур
TEXTURES_DIR = os.path.join(SCRIPT_DIR, "..", "textures")
os.makedirs(TEXTURES_DIR, exist_ok=True)

# Символы Latin-1 Supplement (U+00A0 – U+00FF)
LATIN1_CHARS = "".join(chr(i) for i in range(0x00A0, 0x0100))

# Символы ASCII (U+0020 – U+007E)
ASCII_CHARS = "".join(chr(i) for i in range(32, 127))  # Символы от 32 до 126 (включая пробел и все ASCII знаки)

# Символы кириллицы (U+0400 – U+04FF)
CYRILLIC_CHARS = "".join(chr(i) for i in range(0x0400, 0x0500))

# Добавление специального символа для fallback (например, "□")
FALLBACK_CHAR = "\u25A2" # Это символ "□"

# Объединяем все символы (ASCII, Latin-1 и кириллицу)
ALL_CHARS = ASCII_CHARS + LATIN1_CHARS + CYRILLIC_CHARS + FALLBACK_CHAR

# Путь к виртуальному окружению
VENV_PATH = os.path.join(SCRIPT_DIR, "venv")
#print("VENV_PATH={0}".format(f"{VENV_PATH}"))

def prepare_python_env(): 
    # Проверяем, находимся ли мы в виртуальном окружении
    IN_VENV = sys.prefix != sys.base_prefix

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

def get_font(font_path, fint_size):
    try:
        font = ImageFont.truetype(font_path, fint_size)
        return font
    except IOError:
        print(f"❌ Ошибка: Шрифт {font_path} не найден!")
        return None

def detect_max_char_size(font):
    finded_max_width = 0
    finded_max_height = 0

    # Открываем characters.txt для записи
    characters_txt = os.path.join(SCRIPT_DIR, "..", "characters.txt")
    with open(characters_txt, "w", encoding="utf-8") as char_file:
        for letter in ALL_CHARS:
            # Получаем Unicode код символа
            char_code = ord(letter)

            # Создаем изображение с прозрачным фоном (grayscale)
            img = Image.new("1", (100, 100), 0)  # Используем "1" для черно-белого режима

            draw = ImageDraw.Draw(img)

            # Вычисляем позицию текста
            text_bbox = draw.textbbox((0, 0), letter, font=font)
            text_width = text_bbox[2] - text_bbox[0]
            text_height = text_bbox[3] - text_bbox[1]

            if text_width>finded_max_width:
                finded_max_width=text_width

            if text_height>finded_max_height:
                finded_max_height=text_height

    return finded_max_width, finded_max_height

def get_needed_img_size(char_file_name):
    # Создаем изображение с прозрачным фоном (grayscale)
    img = Image.new("1", (100, 100), 0)

    draw = ImageDraw.Draw(img)

    # Вычисляем позицию текста
    text_bbox = draw.textbbox((0, 0), letter, font=font)
    text_width = text_bbox[2] - text_bbox[0]
    text_height = text_bbox[3] - text_bbox[1]

    return text_width, text_height

prepare_python_env()

# Теперь импортируем Pillow (уже в venv)
from PIL import Image, ImageDraw, ImageFont, ImageFilter

font = get_font(FONT_PATH, FONT_SIZE)
if not font:  # Если шрифт не загружен, выйти из скрипта
    sys.exit("🚫 Завершение работы скрипта из-за ошибки шрифта.")

max_char_img_width,  max_char_img_height = detect_max_char_size(font)
print("max_char_img_width={0} max_char_img_height={1}".format(max_char_img_width, max_char_img_height))

# Открываем characters.txt для записи
characters_txt = os.path.join(SCRIPT_DIR, "..", "characters.txt")
with open(characters_txt, "w", encoding="utf-8") as char_file:
    for letter in ALL_CHARS:
        # Получаем Unicode код символа
        char_code = ord(letter)

        # Имя файла будет основано на коде символа (например, для 'A' -> 0041)
        name = f"char_{char_code:04X}"  # Используем шестнадцатиричный формат с 4 знаками

        char_img_width, char_img_height = get_needed_img_size(name)

        #if char_img_width <= 4:
        #    new_char_img_width = MIN_CHAR_IMG_WIDTH
        #else:
        #    new_char_img_width = char_img_width

        new_char_img_width = char_img_width

        # Создаем черно-белое изображение
        img = Image.new("1", (new_char_img_width, max_char_img_height), 0)

        draw = ImageDraw.Draw(img)

        # Вычисляем позицию текста
        text_bbox = draw.textbbox((0, 0), letter, font=font)
        text_width = text_bbox[2] - text_bbox[0]
        text_height = text_bbox[3] - text_bbox[1]

        x = (new_char_img_width - text_width) #// 2
        y = 0  # Без вертикального центрирования

        print("letter={0} name={1} x={2} y={3} new_char_img_width={4} char_img_width={5}".format(letter, name, x, y, new_char_img_width, text_width))

        # Рисуем букву
        draw.text((x, y), letter, font=font, fill=1)

        img_final = Image.new("RGBA", (new_char_img_width, max_char_img_height), (0, 0, 0, 0))
        pixels_final = img_final.load()

        # Копируем пиксели из черно-белого изображения в изображение в формате RGBA
        pixels = img.load()
        for i in range(new_char_img_width):
            for j in range(max_char_img_height):
                if pixels[i, j] == 0:  # Черный пиксель (0)
                    pixels_final[i, j] = (0, 0, 0, 0)  # Прозрачный
                else:  # Белый пиксель (1)
                    pixels_final[i, j] = (255, 255, 255, 255)  # Белый пиксель с полной непрозрачностью

        # Преобразуем изображение в LA (grayscale + альфа-канал)
        img_la = img_final.convert("LA")

        # Путь до изображения
        img_path = os.path.join(TEXTURES_DIR, f"{name}.png")

        # Сохраняем изображение
        img_la.save(img_path)

        # Записываем в characters.txt
        # Формат: символ, имя файла без .png, ширина текста
        char_file.write(f"{letter}\n{name}\n{char_img_width}\n")

print("✅ Генерация завершена! Файлы сохранены в 'textures/' и записаны в 'characters.txt'.")