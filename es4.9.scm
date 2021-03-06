; library
(define (make-lambda parameters body)
  (cons 'lambda (cons parameters body)))
(define (make-begin seq) (cons 'begin seq))
(define (make-application proc parameters)
  (cons proc parameters))
(define (make-if predicate consequent alternative)
  (list 'if predicate consequent alternative))
(define (make-let vars exps body)
  (list 'let
        (make-let-bindings vars exps)
        body))
(define (make-let-bindings vars exps)
  (map (lambda (var exp)
         (list var exp))
       vars
       exps))
; exercise
(define for-cycle '(for i 1 10 (display i)))
(define (for->combination exp)
  (define (make-step variable lower-limit upper-limit body)
    (make-lambda (list variable 'continuation)
                 (list
                   (make-if (list '<= variable upper-limit)
                            (make-begin (append body
                                                (list (make-application 
                                                        'continuation 
                                                        (list (list '+ variable 1)
                                                              'continuation)))))
                            ''done))))
  (let ((variable (cadr exp))
        (lower-limit (caddr exp))
        (upper-limit (cadddr exp))
        (body (cddddr exp)))
    (make-let '(step)
              (list (make-step variable lower-limit upper-limit body))
              (make-application 'step
                                (list lower-limit 'step)))))
(display (for->combination for-cycle))
(newline)

