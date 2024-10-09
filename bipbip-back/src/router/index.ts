import { Application } from "express";
import { authenticateJWT } from "../middleware/verifyAuth";
import ApiRoutes from "./routes/home.route";
import HealthcheckRoute from "./routes/healthcheck.route";
import VersionRoute from "./routes/version.route";
import UserRoute from "./routes/user.route";
import RegisterRoute from "./routes/register.route";
import AuthenticateRoute from "./routes/authenticate.route";

export default class Routes {
  constructor(app: Application) {
    app.use("/v1/api", ApiRoutes);
    app.use("/v1/api/healthcheck", HealthcheckRoute);
    app.use("/v1/api/version", VersionRoute);
    app.use("/v1/api/user", authenticateJWT, UserRoute);
    app.use("/v1/api/register", RegisterRoute);
    app.use("/v1/api/authenticate", AuthenticateRoute);

    app.use(function(req, res, next) {
        var err = new Error('Not Found');
        res.status(404).json({
            code: 404,
            error: err.message
        })
    });
  }
}
