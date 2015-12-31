let TimeSeries = {
  init(clientOpts) {
    influent
    .createHttpClient(clientOpts)
    .then(function(client) {
      client
      .query("SELECT * FROM potentiometer ORDER BY time DESC LIMIT 5")
      .then(function(result) {
        console.log(result);
      });
    });
  }
}
export default TimeSeries;
