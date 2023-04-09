from flask import Flask, request, jsonify, send_file
from pytube import YouTube
import requests
import os

app = Flask(__name__)

@app.route('/download', methods=['POST'])
def download_video():
    data = request.get_json()
    video_url = data['url']
    format_type = data['format']
    download_sub = data['subtitles'] == 'True'
    youtube = YouTube(video_url)

    # Select the format based on the user's choice
    if format_type == 'mp3':
        video = youtube.streams.filter(only_audio=True).first()
    else:
        video = youtube.streams.get_highest_resolution()

    # Get the file path
    file_path = os.path.join(os.getcwd(), video.default_filename)

    # Download the file
    video.download(output_path=os.getcwd())

    # Download subtitles if requested
    if download_sub:
        sub_url = youtube.captions['a.en'].url
        sub_data = requests.get(sub_url).content
        sub_path = os.path.join(os.getcwd(), video.default_filename[:-3]+'srt')
        with open(sub_path, 'wb') as f:
            f.write(sub_data)

    # Return the file and subtitle to the user
    if download_sub:
        return send_file(file_path, as_attachment=True, attachment_filename=video.default_filename,
                         mimetype='application/octet-stream', add_etags=False), \
               send_file(sub_path, as_attachment=True, attachment_filename=video.default_filename[:-3]+'srt',
                         mimetype='application/octet-stream', add_etags=False)
    else:
        return send_file(file_path, as_attachment=True)