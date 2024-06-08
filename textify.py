# modules
import tkinter as tk
from tkinter import ttk, messagebox
import requests
import json


# text languages
langs = ['Arabic', 'Cantonese', 'Dutch', 'English', 'German', 'Poland', 'Portuguese', 'Russian', 'Spanish',
         'Turkish', 'Ukranian', 'Japanese', 'Korean', 'Hindi', 'Italian', 'Danish', 'Swedish', 'Norwegian',
         'Icelandic', 'Polish', 'French', 'Mandarin Chinese', 'Persian', 'Bengali', 'Urdu']
langs.sort()


# language proficiency levels
lang_levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']


# text size
sizes = ['Short', 'Medium-sized', 'Large']


# main function
def main():
    # main window
    root = tk.Tk()
    root.title("Textify")
    root.geometry("760x1000");
    root.resizable(False, False)



    # string variables
    lang = tk.StringVar()
    lang_level = tk.StringVar()
    topic = tk.StringVar()
    size = tk.StringVar()



    # label widgets
    lbLang = ttk.Label(root, text="Language")
    lbProf = ttk.Label(root, text="Proficiency")
    lbTopic = ttk.Label(root, text="Topic")
    lbSize = ttk.Label(root, text="Text Size")

    # input widgets
    cbLang = ttk.Combobox(root, width=25, textvariable=lang)
    cbProf = ttk.Combobox(root, width=25, textvariable=lang_level)
    entryTopic = ttk.Entry(root, width=25, textvariable=topic)
    cbSize = ttk.Combobox(root, width=25, textvariable=size)

    # action widgets
    button = tk.Button(root, width=45, height=5, text='Generate Text', command=lambda:create_request(lang, lang_level, topic, size, msg))

    # output widgets
    msg = tk.Message(root, width=721, relief=tk.RIDGE)



    # values for combo boxes
    cbLang['values'] = langs
    cbProf['values'] = lang_levels
    cbSize['values'] = sizes

    # default values for combo boxes
    cbLang.current(0)
    cbProf.current(0)
    cbSize.current(0)



    # widgets positioning
    lbLang.place(x=10, y=10, anchor=tk.NW)
    lbProf.place(x=10, y=40, anchor=tk.NW)
    lbTopic.place(x=10, y=70, anchor=tk.NW)
    lbSize.place(x=10, y=100, anchor=tk.NW)

    cbLang.place(x=100, y=10, anchor=tk.NW)
    cbProf.place(x=100, y=40, anchor=tk.NW)
    entryTopic.place(x=100, y=70, anchor=tk.NW)
    cbSize.place(x=100, y=100, anchor=tk.NW)

    button.place(x=360, y=15, anchor=tk.NW)
    msg.place(x=10, y=140, anchor=tk.NW)


    # main loop
    root.mainloop()


# creates a request text for the API
def create_request(lang, lang_level, topic, size, msg):
    if (topic.get() == ''):
        tk.messagebox.showerror("Blank Field", "Inform a topic for the text")
    else:
        txt = f"write a {size.get().lower()} text in {lang.get()} ({lang_level.get()} level) about {topic.get()}"
        ai_msg = ai_text_generate(txt)['openai']

        #msg.configure(text=ai_msg['generated_text'][2:].replace('\n\n', '\n'))
        msg.configure(text=ai_msg['generated_text'][2:])
        print(f"Message cost: ${ai_msg['cost']}")


# Eden AI - AI Text Generator
# https://www.edenai.co/post/how-to-generate-text-with-python
def ai_text_generate(msg):
    headers = {"Authorization" : "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMjhkZjc2ODgtZDIwZC00NzMyLWFlOTAtMDU3ODc5NTdlNDU0IiwidHlwZSI6ImFwaV90b2tlbiJ9.QD26SIx0EHF_F6U6SfppRcOBuTvfzkPY97CuQJhlbQQ"}

    url = "https://api.edenai.run/v2/text/generation"

    payload = {
        "providers" : "openai",
        "text" : msg,
        "temperature" : 0.2,
        "max_token" : 250
    }

    response = requests.post(url, json=payload, headers=headers)
    result = json.loads(response.text)

    return result



if (__name__ == '__main__'):
    main()
