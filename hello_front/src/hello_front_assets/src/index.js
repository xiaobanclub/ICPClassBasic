import { hello_front } from "../../declarations/hello_front";

async function post() {
  let post_button = document.getElementById("post");
  let error = document.getElementById("error");
  error.innerText = "";

  post_button.disabled = true;
  let textarea = document.getElementById("message");
  let text = textarea.value;
  let otp = document.getElementById("otp").value;

  try {
    await hello_front.post(otp, text);
    textarea.value = "";
  } catch (err) {
    console.log(err);
    error.innerText = "Post Failed!\nerr detail: \n" + err.message;
  }
  post_button.disabled = false;
}

async function setAuthor() {
  let post_button = document.getElementById("setAuthor");
  let error = document.getElementById("error2");
  error.innerText = "";

  post_button.disabled = true;
  let textarea = document.getElementById("author");
  let text = textarea.value;
  let otp = document.getElementById("otp").value;

  try {
    await hello_front.set_name(otp, text);
    textarea.value = "";
  } catch (err) {
    console.log(err);
    error.innerText = "set author name failed!\nerr detail: \n" + err.message;
  }
  post_button.disabled = false;
}


var num_posts = 0;
async function load_posts() {
  let posts_section = document.getElementById("posts");
  let posts = await hello_front.posts(0);

  if (num_posts == posts.length) return;
  num_posts = posts.length;

  posts_section.replaceChildren([]);

  for (var i = 0; i < posts.length; i++) {
    let post = document.createElement("p");
    post.innerText = posts[i].author + "=> [" + posts[i].text + "] @ " + posts[i].time;
    console.log(posts[i]);
    posts_section.appendChild(post);
  }
}

var num_follows = 0;
async function load_follows() {
  let follows_section = document.getElementById("follows");
  let follows = await hello_front.follows();

  if (num_follows == follows.length) return;
  num_follows = follows.length;

  follows_section.replaceChildren([]);

  for (var i = 0; i < follows.length; i++) {
    let f = document.createElement("p");
    f.innerText = follows[i];
    follows_section.appendChild(f);
  }
}

var num_timeline = 0;
async function load_timeline() {
  let timeline_section = document.getElementById("timeline");
  let timeline = await hello_front.timeline(0);

  if (num_timeline == timeline.length) return;
  num_timeline = timeline.length;

  timeline_section.replaceChildren([]);

  for (var i = 0; i < timeline.length; i++) {
    let f = document.createElement("p");
    f.innerText = "author:" + timeline[i].author + ", createTime: " + timeline[i].time;
    timeline_section.appendChild(f);
  }
}

function load() {
  let post_button = document.getElementById("post");
  post_button.onclick = post;
  let author_button = document.getElementById("setAuthor");
  author_button.onclick = setAuthor;
  setInterval(load_posts, 3000);
  setInterval(load_follows, 3000);
  setInterval(load_timeline, 3000);
}

window.onload = load