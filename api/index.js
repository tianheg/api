import app from "../server.js";

export default async (req, res) => {
	await app.ready();
	app.server.emit("request", req, res);
};
