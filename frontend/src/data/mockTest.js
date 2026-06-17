// src/data/mockTest.js

export const availableTests = [
  { id: "test_cbt_1", title: "TOEIC CBT Format - Mock Test 1", difficulty: "Medium", totalQuestions: 200 },
  { id: "test_cbt_2", title: "TOEIC CBT Format - Mock Test 2", difficulty: "Hard", totalQuestions: 200 }
];

export const testPartsMetadata = [
  { id: 'part1', title: 'Part 1: Photographs', questionCount: 6, section: 'listening' },
  { id: 'part2', title: 'Part 2: Question-Response', questionCount: 25, section: 'listening' },
  { id: 'part3', title: 'Part 3: Conversations', questionCount: 39, section: 'listening' },
  { id: 'part4', title: 'Part 4: Talks', questionCount: 30, section: 'listening' },
  { id: 'part5', title: 'Part 5: Incomplete Sentences', questionCount: 30, section: 'reading' },
  { id: 'part6', title: 'Part 6: Text Completion', questionCount: 16, section: 'reading' },
  { id: 'part7', title: 'Part 7: Reading Comprehension', questionCount: 54, section: 'reading' }
];

// In a real app, this would be fetched via API. For now, we reuse the same data structure.
export const getMockTest = (testId) => {
  return {
    id: testId,
    title: availableTests.find(t => t.id === testId)?.title || "Mock Test",
    totalQuestions: 200,
    timeLimitSeconds: 7200, // 2 hours
    sections: [
      {
        id: "listening",
        title: "Listening",
        startQuestion: 1,
        endQuestion: 100,
        questions: [
          // Part 1: Picture Description
          {
            id: 1,
            type: "picture",
            part: "part1",
            instruction: "Select the one statement that best describes what you see in the picture.",
            image: "https://images.unsplash.com/photo-1600880292203-757bb62b4baf?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
            options: ["(A)", "(B)", "(C)", "(D)"],
          },
          // Part 2: Question-Response
          {
            id: 7,
            type: "response",
            part: "part2",
            instruction: "Select the best response to the question.",
            options: ["(A)", "(B)", "(C)"],
          },
          // Part 3: Conversations
          {
            id: 32,
            type: "conversation",
            part: "part3",
            instruction: "Select the best response to the question.",
            groupId: "g_32_34",
            questionText: "32. Where most likely are the speakers?",
            options: ["(A) At a library", "(B) At a bookstore", "(C) At a coffee shop", "(D) At an art gallery"]
          },
          {
            id: 33,
            type: "conversation",
            part: "part3",
            instruction: "Select the best response to the question.",
            groupId: "g_32_34",
            questionText: "33. What does the woman want to do?",
            options: ["(A) Buy a book", "(B) Meet a friend", "(C) Read a magazine", "(D) Order some food"]
          },
          {
            id: 34,
            type: "conversation",
            part: "part3",
            instruction: "Select the best response to the question.",
            groupId: "g_32_34",
            questionText: "34. What does the man suggest?",
            options: ["(A) Wait for ten minutes", "(B) Go to another store", "(C) Check the website", "(D) Ask the manager"]
          }
        ]
      },
      {
        id: "reading",
        title: "Reading",
        startQuestion: 101,
        endQuestion: 200,
        questions: [
          // Part 5: Incomplete Sentences
          {
            id: 101,
            type: "incomplete_sentence",
            part: "part5",
            instruction: "Select the best answer to complete the sentence.",
            questionText: "101. The new software update will be available to all employees ------- next week.",
            options: ["(A) begin", "(B) beginning", "(C) began", "(D) to begin"]
          },
          // Part 6: Text Completion
          {
            id: 131,
            type: "text_completion",
            part: "part6",
            instruction: "Select the best answer to complete the text.",
            groupId: "p_131_134"
          },
          {
            id: 132,
            type: "text_completion",
            part: "part6",
            instruction: "Select the best answer to complete the text.",
            groupId: "p_131_134"
          },
          {
            id: 133,
            type: "text_completion",
            part: "part6",
            instruction: "Select the best answer to complete the text.",
            groupId: "p_131_134",
            options: [
              "(A) First-class flight tickets and tour packages are available online only.",
              "(B) The website includes information about Indonesian tourist attractions.",
              "(C) Our best-selling package is luxury tours to the Java Islands.",
              "(D) There you will find thousands of hotels starting at $20 per night."
            ]
          },
          {
            id: 134,
            type: "text_completion",
            part: "part6",
            instruction: "Select the best answer to complete the text.",
            groupId: "p_131_134"
          },
          // Part 7: Reading Comprehension
          {
            id: 196,
            type: "passage",
            part: "part7",
            instruction: "Select the best answer for each question.",
            groupId: "p_196_200",
            questionText: "196. What is the main purpose of the email?",
            options: [
              "(A) To request a refund",
              "(B) To ask about product dimensions",
              "(C) To confirm an order",
              "(D) To schedule a delivery"
            ]
          },
          {
            id: 197,
            type: "passage",
            part: "part7",
            instruction: "Select the best answer for each question.",
            groupId: "p_196_200",
            questionText: "197. Which color does Frederik Duvall want?",
            options: [
              "(A) Ocean blue",
              "(B) Sandy beige",
              "(C) Cloudy white",
              "(D) He does not specify a color"
            ]
          },
          {
            id: 200,
            type: "passage",
            part: "part7",
            instruction: "Select the best answer for each question.",
            groupId: "p_196_200",
            questionText: "200. In the customer's message, the word \"picky\" is closest in meaning to",
            options: [
              "(A) difficult to please",
              "(B) concerned about accuracy",
              "(C) sensitive to negative comments",
              "(D) easy to satisfy"
            ]
          }
        ]
      }
    ],
    groups: {
      "g_32_34": {
        id: "g_32_34",
        type: "audio_group",
        contentTitle: "Questions 32-34 refer to the following conversation."
      },
      "p_131_134": {
        id: "p_131_134",
        type: "text_group",
        content: `Let's explore Indonesia with our Indo Packages. With over 10 years in business, we are confident that you will enjoy every single moment you spend there. You can ---[131]--- lie on the sandy beaches of Bali, shop in the bustling malls of Jakarta, or hike through the thick jungles of Sumatra. And if you are on a ---[132]--- budget, you can find many good deals with us. Just visit our website at indopackages.com. ---[133]--- You can also book ---[134]--- flights on our website. So, what are you waiting for? Call us at 902-555-0166 and set a date for your adventure!`
      },
      "p_196_200": {
        id: "p_196_200",
        type: "passage_group",
        contentTitle: "Questions 196-200 refer to the following webpage and email.",
        contentHtml: `<div style="border: 1px solid #ccc; padding: 10px; border-radius: 4px; margin-top: 10px;">
          <div style="background:#eee; padding: 5px; border-bottom: 1px solid #ccc; display: flex; align-items:center; gap: 10px;">
            <span>← → ↻</span> <input type="text" value="https://www.silafurniture.com/" disabled style="flex:1; padding: 4px;" />
          </div>
          <div style="display:flex; border-bottom: 1px solid #ccc;">
            <div style="flex:1; padding: 8px; text-align:center; border-right: 1px solid #ccc;">Home</div>
            <div style="flex:1; padding: 8px; text-align:center; border-right: 1px solid #ccc;">Product</div>
            <div style="flex:1; padding: 8px; text-align:center; border-right: 1px solid #ccc;">Offers</div>
            <div style="flex:1; padding: 8px; text-align:center; background: #ddd; font-weight:bold;">Message us</div>
          </div>
          <div style="padding: 10px;">
            <p><strong>From:</strong> Frederik Duvall &nbsp;&nbsp; <strong>Date:</strong> September 16</p>
            <p><strong>Product: Lucas Storage Bed Frame</strong></p>
            <p>I am interested in purchasing the Lucas Storage Bed Frame, but I have some concerns about its size. Specifically, I am worried that the bed frame may not fit in the fixed space in the attic of my newly rented house. Is it possible to get the Lucas Storage Bed Frame in a smaller size, around 190 cm in length, 130 cm in width? I'm not <em>picky</em> about the color, so any available option would be great. Thank you for your help.</p>
          </div>
        </div>`
      }
    }
  };
};
