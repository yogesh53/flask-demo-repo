import os
import psycopg2
from flask import Flask, render_template, request, jsonify

app = Flask(__name__)


def get_db_connection():
    return psycopg2.connect(
        host=os.environ["POSTGRES_HOST"],
        port=os.environ.get("POSTGRES_PORT", "5432"),
        database=os.environ["POSTGRES_DB"],
        user=os.environ["POSTGRES_USER"],
        password=os.environ["POSTGRES_PASSWORD"]
    )


def init_db():
    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("""
        CREATE TABLE IF NOT EXISTS messages (
            id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
            message TEXT NOT NULL
        );
    """)

    conn.commit()
    cur.close()
    conn.close()


@app.route("/health")
def health():
    return jsonify({"status": "healthy"}), 200

@app.route("/ready")
def ready():
    try:
        conn = get_db_connection()
        conn.close()

        return jsonify({"status": "ready"}), 200

    except Exception:
        return jsonify({"status": "not ready"}), 503
@app.route("/")
def hello():
    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("SELECT message FROM messages ORDER BY id")
    messages = cur.fetchall()

    cur.close()
    conn.close()

    return render_template("index.html", messages=messages)


@app.route("/submit", methods=["POST"])
def submit():
    new_message = request.form.get("new_message")

    if not new_message:
        return jsonify({"error": "Message cannot be empty"}), 400

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute(
        "INSERT INTO messages (message) VALUES (%s) RETURNING id",
        (new_message,)
    )

    message_id = cur.fetchone()[0]

    conn.commit()

    cur.close()
    conn.close()

    return jsonify({
        "id": message_id,
        "message": new_message
    }), 201


if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=5000)