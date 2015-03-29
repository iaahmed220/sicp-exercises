; data structure
(define (=number? exp num)
  (and (number? exp) (= exp num)))
(define (not-zero? exp)
  (not (=number? exp 0)))
(define (variable? x) (symbol? x))
(define (same-variable? v1 v2)
  (and (variable? v1) (variable? v2) (eq? v1 v2)))
(define (make-sum . addends)
  (let ((removed-zeros (filter not-zero? addends))) 
    (cond ((eq? '() removed-zeros) 0)
        ; sum all numbers ((and (number? a1) (number? a2)) (+ a1 a2))
        (else (cons '+ removed-zeros)))))
(define (sum? x)
  (and (pair? x) (eq? (car x) '+)))
(define (addend s) (cadr s))
(define (augend s) 
  (let ((others (cddr s)))
    (if (eq? '() others)
        0
        (cons '+ others))))
(define (make-product m1 m2)
  (cond ((or (=number? m1 0) (=number? m2 0)) 0)
        ((=number? m1 1) m2)
        ((=number? m2 1) m1)
        ((and (number? m1) (number? m2)) (* m1 m2))
        (else (list '* m1 m2))))
(define (product? x)
  (and (pair? x) (eq? (car x) '*)))
(define (multiplier p) (cadr p))
(define (multiplicand p) (caddr p))
; deriv
(define (deriv exp var)
  (display exp)
  (newline)
  (cond ((number? exp) 0)
        ((variable? exp)
         (if (same-variable? exp var) 1 0))
        ((sum? exp)
         (make-sum (deriv (addend exp) var)
                   (deriv (augend exp) var)))
        ((product? exp)
         (make-sum
           (make-product (multiplier exp)
                         (deriv (multiplicand exp) var))
           (make-product (deriv (multiplier exp) var)
                         (multiplicand exp))))
        ((exponentiation? exp)
         (make-product 
             (make-product (exponent exp)
                           (make-exponentiation (base exp)
                                                (- (exponent exp) 1)))
             (deriv (base exp)
                    var)))
        (else
          (error "unknown expression type -- DERIV" exp))))
; new data structure
(define (make-exponentiation u n)
  (cond ((= n 0)
         1)
        ((= n 1)
         u)
        (else 
         (list '** u n))))
(define (exponentiation? exp)
  (and (pair? exp)
       (eq? '** (car exp))))
(define (base exponentiation)
  (cadr exponentiation))
(define (exponent exponentiation)
  (caddr exponentiation))
