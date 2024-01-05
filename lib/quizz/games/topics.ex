defmodule Quizz.Games.Topics do
  def generate(topics) when is_list(topics) do
    {:ok, res} =
      OpenAI.chat_completion(
        model: "gpt-4-1106-preview",
        response_format: %{type: "json_object"},
        messages: [
          %{
            role: "system",
            content: "
            You are a quizz expert capable to create a list of topics for a quiz.
            The user will pass a list of topics already used, so you have to generate a list of different topics.
            You must provide at least 5 topics.
            Be creative with your topics, you can use any topic you want.
            You must generate images to illustrate each topic.
            Respond with a JSON object like this exemple:
            topics: [
              {title: 'maths', img: 'fill_with_img_url'},
              {title: 'history', img: 'fill_with_img_url'},
              {title: 'geography', img: 'fill_with_img_url'},
              {title: 'science', img: 'fill_with_img_url'}
            ]
            "
          },
          %{
            role: "user",
            content: "topics: #{topics}"
          }
        ]
      )

    [choice | _] = res.choices

    #  Parse the response
    {:ok, decoded_obj} = Jason.decode(choice["message"]["content"])

    decoded_obj["topics"]
  end
end
