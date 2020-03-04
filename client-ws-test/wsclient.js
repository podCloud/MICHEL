const { Socket } = require("phoenix-channels");

const VALID_TOKEN =
  "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ0ZXN0In0.S9WIT8_Q8P4WBrDJLhfSw3uAdWoxIjnMEN92q1q0BabfXzyBOrRxeleep13jypJxTN8KLz5Kz8OlpdXXgx5qGqBhwfIi8pt9vL4vHcq5FwkuaL1FtuReFrRD5Qdz6QdruzTfyjggsXfGrtn30197HmtpBPirhrEWj9RbcyBIj7_NZ_Jb_wmULxO7BkstSkNpCHDwq_83Sfv8D7PKOQEGIpI_-Ayiv-y8vWISQPYRkHiJFun5VFMLVkpnMNJHQ3vOuWYUvQObjYOzmGG8EPbZccpRuh02uHr-fQVTL3uSTo7tWc6uJVH3srsN6Q730HcByludA7LkcxtldJnTsUxfdw";
// const INVALID_TOKEN =
//   "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ0ZXN0MiJ9.gjUjN51-lnr5yQpnZgiK2NGl_bs6FV8o8QVOr7hMjy5hQbmC-qEbFHAwJjf1Ufux6GTtPHre9f-NZl_E0F8iCvK_ofP5OMuHU7EYyxyLViKy5wAJvWfmzJN_4qAFJwk3yp9eH54x-7LruLVuh_tngvSNZISmXCczDnpegtbk2VtiEjMcM1hkQnn_PlYxpIk34g63a81wV278g_yia2Yfu8wi92kQc7CsDlMhC8QZUad6qKwVkQJX7TPriCVlbQ_MfbavXTGi5GhO52I8o7I1qx1xNFNCVARMLu9JDxLjA56O2l2316_Yc5r49nsOvb3hy3AIek2Tj-HlxBy_f4VXcw";

let socket = new Socket("ws://localhost:4000/socket", {
  params: {
    token: VALID_TOKEN
    // token: INVALID_TOKEN
  }
});

socket.connect();

let channel = socket.channel("room:lobby", {});

channel
  .join()
  .receive("ok", resp => {
    channel.on("coucou", params => {
      console.log(params);
    });
    channel.push("coucou", { message: "Salut !" });
    console.log("Joined successfully", resp);
  })
  .receive("error", resp => {
    console.log("Unable to join", resp);
  });
