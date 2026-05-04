const axios = require("axios");

exports.chatBot = async (req, res) => {
  try {
    const { message } = req.body;

    const response = await axios.post(
      "https://openrouter.ai/api/v1/chat/completions",
      {
        model: "openai/gpt-oss-20b:free",
        messages: [
          {
            role: "system",
            content: `
            Kamu adalah Gelatix Assistant.
            Bantu user terkait:
            - event
            - tiket
            - voucher
            - akun
            - pertanyaan umum
            Jawab singkat, jelas, dan ramah.
            `
          },
          {
            role: "user",
            content: message
          }
        ]
      },
      {
        headers: {
          Authorization:
            `Bearer ${process.env.OPENROUTER_API_KEY}`,
          "Content-Type":
            "application/json",
          "HTTP-Referer":
            "http://localhost:5000",
          "X-Title":
            "Gelatix App"
        }
      }
    );

    console.log(response.data);

    const reply =
      response.data.choices[0]
        .message.content;

    res.json({
      reply
    });

  } catch (error) {
    console.log(
      error.response?.data ||
      error.message
    );

    res.status(500).json({
    message:
        error.response?.data ||
        error.message
    });
  }
};