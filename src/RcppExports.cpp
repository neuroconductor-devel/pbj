// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <RcppArmadillo.h>
#include <Rcpp.h>

using namespace Rcpp;

// calcBootStats
arma::mat calcBootStats(arma::mat images, arma::mat X, arma::mat Xred, arma::mat coefficients, arma::uvec peind);
RcppExport SEXP _pbj_calcBootStats(SEXP imagesSEXP, SEXP XSEXP, SEXP XredSEXP, SEXP coefficientsSEXP, SEXP peindSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< arma::mat >::type images(imagesSEXP);
    Rcpp::traits::input_parameter< arma::mat >::type X(XSEXP);
    Rcpp::traits::input_parameter< arma::mat >::type Xred(XredSEXP);
    Rcpp::traits::input_parameter< arma::mat >::type coefficients(coefficientsSEXP);
    Rcpp::traits::input_parameter< arma::uvec >::type peind(peindSEXP);
    rcpp_result_gen = Rcpp::wrap(calcBootStats(images, X, Xred, coefficients, peind));
    return rcpp_result_gen;
END_RCPP
}
// pbjES
arma::mat pbjES(arma::vec mu, arma::mat M, signed long chsq, int df, int nboot);
RcppExport SEXP _pbj_pbjES(SEXP muSEXP, SEXP MSEXP, SEXP chsqSEXP, SEXP dfSEXP, SEXP nbootSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< arma::vec >::type mu(muSEXP);
    Rcpp::traits::input_parameter< arma::mat >::type M(MSEXP);
    Rcpp::traits::input_parameter< signed long >::type chsq(chsqSEXP);
    Rcpp::traits::input_parameter< int >::type df(dfSEXP);
    Rcpp::traits::input_parameter< int >::type nboot(nbootSEXP);
    rcpp_result_gen = Rcpp::wrap(pbjES(mu, M, chsq, df, nboot));
    return rcpp_result_gen;
END_RCPP
}
// pbjESboundary
arma::mat pbjESboundary(arma::mat M, int nboot);
RcppExport SEXP _pbj_pbjESboundary(SEXP MSEXP, SEXP nbootSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< arma::mat >::type M(MSEXP);
    Rcpp::traits::input_parameter< int >::type nboot(nbootSEXP);
    rcpp_result_gen = Rcpp::wrap(pbjESboundary(M, nboot));
    return rcpp_result_gen;
END_RCPP
}

static const R_CallMethodDef CallEntries[] = {
    {"_pbj_calcBootStats", (DL_FUNC) &_pbj_calcBootStats, 5},
    {"_pbj_pbjES", (DL_FUNC) &_pbj_pbjES, 5},
    {"_pbj_pbjESboundary", (DL_FUNC) &_pbj_pbjESboundary, 2},
    {NULL, NULL, 0}
};

RcppExport void R_init_pbj(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
