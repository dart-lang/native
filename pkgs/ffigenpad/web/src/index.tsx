/* @refresh reload */
import { render } from "solid-js/web";
import "@fontsource-variable/reddit-mono";
import "./index.css";
import App from "./App";

const root = document.getElementById("root");

render(() => <App />, root!);
