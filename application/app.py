from flask import Flask, render_template
import random

app = Flask(__name__)

quotes = [
    "The only way to do great work is to love what you do. - Steve Jobs",
    "Strive not to be a success, but rather to be of value. - Albert Einstein",
    "The mind is everything. What you think you become. - Buddha",
    "Your time is limited, so don't waste it living someone else's life. - Steve Jobs",
    "The best way to predict the future is to create it. - Peter Drucker"
]

@app.route('/')
def home():
    quote = random.choice(quotes)
    return render_template('index.html', quote=quote)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
