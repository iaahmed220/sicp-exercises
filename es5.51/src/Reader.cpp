#include "reader.h"
#include "symbol.h"
#include "cons.h"
#include "nil.h"
#include "integer.h"
#include "string.h"
#include "float.h"
#include "bool.h"
#include <iostream>
#include <boost/regex.hpp>
using namespace std;

// https://igor.io/2012/12/08/sexpr-reader.html
List* Reader::parse(vector<string> input)
{
	auto ast = vector<Value*>();

    for (int i = 0; i < input.size(); ++i) {
		auto token = input.at(i);

		if ("'" == token) {
			// wrap quoted value
			auto temp = this->parse_quoted_token(input, i);
			auto parsed_token = get<0>(temp);
			i = get<1>(temp);
			ast.push_back(parsed_token);
		    continue;
		}

        if ("(" != token && ")" != token) {
            // extract atoms
            ast.push_back(this->normalize_atom(token));
            continue;
        }

		if ("(" == token) {
			// parse list recursively
			auto temp = this->extract_list_tokens(input, i);
			auto list_tokens = get<0>(temp);
			i = get<1>(temp);
			ast.push_back(this->parse(list_tokens));	
			continue;
		}
    }

    return Cons::from_vector(ast);
}

tuple<Value*,int> Reader::parse_quoted_token(vector<string> tokens, int i)
{
    // skip past quote char
	i++;
    // quoted atom
	if ("(" != tokens.at(i)) {
		auto atom = this->normalize_atom(tokens.at(i));
		return make_tuple(
			Cons::from_vector({ new Symbol("quote"), atom }),
			i
		);
	}
    // quoted list
	auto temp = this->extract_list_tokens(tokens, i);
	auto list_tokens = get<0>(temp);
	i = get<1>(temp);
	return make_tuple(
		Cons::from_vector({ new Symbol("quote"), this->parse(list_tokens) }),
		i
	);
}


Value* Reader::normalize_atom(string token)
{
	boost::smatch what;

    // an integer
	boost::regex int_expr("[0-9]+");
	if (boost::regex_match(token, int_expr)) {
		return new Integer(stoi(token));
	}

    // a float
	boost::regex float_expr("[0-9]+\\.[0-9]+");
	if (boost::regex_match(token, float_expr)) {
		return new Float(stof(token));
    }

    // a string
	boost::regex string_expr("\"(.*)\"");
	if (boost::regex_match(token, what, string_expr)) {
		return new String(what[1]);
	}

    // a boolean
    if (token == "#t") {
        return new Bool(true);
    } else if (token == "#f") {
        return new Bool(false);
    }

    return new Symbol(token);
}

tuple<vector<string>,int> Reader::extract_list_tokens(vector<string> tokens, int i)
{
	int level = 0;
	int init = i;

	for (int length = tokens.size(); i < length; i++) {
		string token = tokens.at(i);
		
		if ("(" == token) {
			level++;
		}

		if (")" == token) {
			level--;
		}

	    if (0 == level) {
            // TODO: prellocate capacity of slice
            auto slice = vector<string>();
            for (int j = init + 1; j < i; j++) {
                slice.push_back(tokens.at(j));
            }
            return make_tuple(
                slice, 
                i
            );
        }
	}
}
