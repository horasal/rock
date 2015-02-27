import ../frontend/Token
import Conditional, Expression, If, Node, Scope, Statement, Visitor
import tinker/[Errors, Resolver, Response, Trail]

Else: class extends Conditional {
    parent: If

    init: func ~_else (.token) { super(null, token) }

    setIf: func(=parent)
    getIf: func -> If { parent }

    clone: func -> This {
        copy := new(token)
        body list each(|e| copy body add(e clone()))
        copy
    }

    accept: func (visitor: Visitor) {
        visitor visitElse(this)
    }

    toString: func -> String {
        "else " + body toString()
    }

    resolve: func(trail: Trail, res: Resolver) -> Response {
        trail push(this)
        if (!parent) { res throwError(LonesomeElse new(this)) }
        response := body resolve(trail, res)
        trail pop(this)
        return response
        
    }

}

LonesomeElse: class extends Error {

    first: Statement
    init: func (=first) {
        message = first token formatMessage("Found a single-standing `else`. (Note, there must be an if before)", "[ERROR]")
    }
    format: func -> String {
        message
    }

}
