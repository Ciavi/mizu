namespace Mizu {
    public enum MatchScore {
        POOR = 50000,
        BELOW_AVERAGE = 60000,
        AVERAGE = 70000,
        ABOVE_AVERAGE = 75000,
        GOOD = 80000,
        VERY_GOOD = 85000,
        EXCELLENT = 90000,
        PERFECT = 100000,

        INCREMENT_DELTA = 2000,
        INCREMENT_SMALL = 5000,
        INCREMENT_MEDIUM = 10000,
        INCREMENT_LARGE = 20000
    }

    [Flags]
    public enum MatcherFlags {
        NO_REVERSED = 1 << 0,
        NO_SUBSTRING = 1 << 1,
        NO_PARTIAL = 1 << 2,
        NO_FUZZY = 1 << 3
    }

    public struct Matcher {
        public Regex regex;
        public MatchScore score;
    }

    class Fuzzier {
        public string query;

        public Fuzzier(string query) {
            this.query = query;
        }

        public int match(string haystack, MatcherFlags matcher_flags = 0, RegexCompileFlags regex_flags = RegexCompileFlags.OPTIMIZE) {
            var matchers = get_matchers(matcher_flags, regex_flags);

            var highest = 0;
            foreach(var matcher in matchers) {
                if(matcher != null) {
                    if(matcher.regex.match(haystack)) {
                        if(matcher.score > highest) highest = matcher.score;
                        break;
                    }
                }
            }

            return highest;
        }

        private List<Matcher?> get_matchers(MatcherFlags matcher_flags = 0, RegexCompileFlags regex_flags = RegexCompileFlags.OPTIMIZE) {
            var e_query = Regex.escape_string(query.strip());

            var results = new List<Matcher?>();

            try {
                Matcher matcher = {
                    regex: new Regex("^(%s)$".printf(e_query), regex_flags),
                    score: MatchScore.PERFECT
                };
                results.append(matcher);

                matcher = {
                    regex: new Regex("^(%s)".printf(e_query), regex_flags),
                    score: MatchScore.EXCELLENT
                };
                results.append(matcher);
                
                matcher = {
                    regex: new Regex("\\b(%s)".printf(e_query), regex_flags),
                    score: MatchScore.VERY_GOOD
                };
                results.append(matcher);

                string[] t_query = Regex.split_simple("\\s+", query.strip());
                if(t_query.length >= 2) {
                    string[] et_query = {};
                    foreach(unowned string token in t_query) et_query +=  Regex.escape_string(token);

                    var pattern = "\\b(%s)".printf(string.joinv(").+\\b(", et_query));

                    matcher = {
                        regex: new Regex(pattern, regex_flags),
                        score: MatchScore.GOOD
                    };
                    results.append(matcher);

                    if(!(MatcherFlags.NO_REVERSED in matcher_flags)) {
                        if(et_query.length == 2) {
                            var reversed = "\\b(%s)".printf(string.join(").+\\b(", et_query[1], et_query[0], null));

                            matcher = {
                                regex: new Regex(reversed, regex_flags),
                                score: MatchScore.GOOD - MatchScore.INCREMENT_DELTA
                            };
                            results.append(matcher);
                        } else {
                            var horrid = "\\b((?:%s))".printf(string.joinv(")|(?:", et_query));
                            var order = "";

                            for(int i = 0; i < et_query.length; i++) {
                                var is_last = i == et_query.length - 1;
                                order += horrid;

                                if(!is_last) order += ".+";
                            }

                            matcher = {
                                regex: new Regex(order, regex_flags),
                                score: MatchScore.AVERAGE + MatchScore.INCREMENT_DELTA
                            };
                            results.append(matcher);
                        }
                    }
                }

                if(!(MatcherFlags.NO_SUBSTRING in matcher_flags)) {
                    matcher = {
                        regex: new Regex("(%s)".printf(e_query), regex_flags),
                        score: MatchScore.BELOW_AVERAGE
                    };
                    results.append(matcher);
                }

                string[] c_query = Regex.split_simple("\\s*", query.strip());
                string[] ec_query = {};
                foreach(unowned string c in c_query) ec_query += Regex.escape_string(c);

                if(!(MatcherFlags.NO_PARTIAL in matcher_flags) && t_query.length == 1 && c_query.length <= 5) {
                    string pattern = "\\b(%s)".printf(string.joinv(").+\\b(", ec_query));

                    matcher = {
                        regex: new Regex(pattern, regex_flags),
                        score: MatchScore.ABOVE_AVERAGE
                    };
                    results.append(matcher);
                }

                if(!(MatcherFlags.NO_FUZZY in matcher_flags) && ec_query.length > 0) {
                    string pattern = "\\b(%s)".printf(string.joinv(").*(", ec_query));

                    matcher = {
                        regex: new Regex(pattern, regex_flags),
                        score: MatchScore.POOR
                    };
                    results.append(matcher);
                }
            } catch (Error e) {
                stderr.printf("%s\n", e.message);
            }

            results.sort_with_data((a, b) => {
                return b.score - a.score;
            });

            return results;
        }
    }
}