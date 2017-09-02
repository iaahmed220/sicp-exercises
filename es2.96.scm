; forked from previous exercise (2.95)
(define *operation-table* (make-hash-table))
(define (put op types proc)
    (hash-table/put! 
          *operation-table* 
              (list op types) 
                  proc))
(define (get op types)
    (hash-table/get 
          *operation-table* 
              (list op types) 
                  #f))
(define (type-tag exp)
  (cond ((number? exp) 'number)
        (else (car exp))))
(define (contents exp)
  (cond ((number? exp) exp)
        (else (cadr exp))))
(define (attach-tag tag contents)
  (cond ((number? contents) contents)
        (else (list tag contents))))
(define (apply-generic op . args)
  (let ((type-tags (map type-tag args)))
    (let ((proc (get op type-tags)))
      (if proc
        (apply proc (map contents args))
        (error "Cannot find procedure for these types -- APPLY-GENERIC" (list op type-tags))))))
(define (adjoin-term term term-list)
  (if (=zero? (coeff term))
    term-list
    (cons term term-list)))
(define (the-empty-termlist) '())
(define (first-term term-list) (car term-list))
(define (rest-terms term-list) (cdr term-list))
(define (empty-termlist? term-list) (null? term-list))
(define (make-term order coeff) (list order coeff))
(define (order term) (car term))
(define (coeff term) (cadr term))
(define (add-terms L1 L2)
  (cond ((empty-termlist? L1) L2)
        ((empty-termlist? L2) L1)
        (else
          (let ((t1 (first-term L1)) (t2 (first-term L2)))
            (cond ((> (order t1) (order t2))
                   (adjoin-term
                     t1 (add-terms (rest-terms L1) L2)))
                  ((< (order t1) (order t2))
                   (adjoin-term
                     t2 (add-terms L1 (rest-terms L2))))
                  (else
                    (adjoin-term
                      (make-term (order t1)
                                 (add (coeff t1) (coeff t2)))
                      (add-terms (rest-terms L1)
                                 (rest-terms L2)))))))))
(define (mul-terms L1 L2)
  (if (empty-termlist? L1)
    (the-empty-termlist)
    (add-terms (mul-term-by-all-terms (first-term L1) L2)
               (mul-terms (rest-terms L1) L2))))
(define (mul-term-by-all-terms t1 L)
  (if (empty-termlist? L)
    (the-empty-termlist)
    (let ((t2 (first-term L)))
      (adjoin-term
        (make-term (+ (order t1) (order t2))
                   (mul (coeff t1) (coeff t2)))(mul-term-by-all-terms t1 (rest-terms L))))))
(define (opposite-term term)
  (make-term (order term)
             (- 0 (coeff term))))
(define (sub-terms L1 L2)
  (add-terms L1 (map opposite-term L2)))
(define (install-polynomial-package)

  ;; internal procedures
  ;; representation of poly
  (define (make-poly variable term-list)
    (cons variable term-list))
  (define (variable p) (car p))
  (define (term-list p) (cdr p))
  (define (variable? x) (symbol? x))
  (define (same-variable? v1 v2)
    (and (variable? v1) (variable? v2) (eq? v1 v2)))
  (define (add-poly p1 p2)
    (if (same-variable? (variable p1) (variable p2))
      (make-poly (variable p1)
                 (add-terms (term-list p1)
                            (term-list p2)))
      (error "Polys not in same var -- ADD-POLY"
             (list p1 p2))))
  (define (mul-poly p1 p2)
    (if (same-variable? (variable p1) (variable p2))
      (make-poly (variable p1)
                 (mul-terms (term-list p1)
                            (term-list p2)))
      (error "Polys not in same var -- MUL-POLY"
             (list p1 p2))))
  (define (mul-poly-number p n)
    (make-poly (variable p)
               (map (lambda (term)
                      (make-term (order term) (mul (coeff term) (attach-tag 'number n))))
                    (term-list p))))
  (define (tag p) (attach-tag 'polynomial p))
  (put 'add '(polynomial polynomial)
       (lambda (p1 p2) (tag (add-poly p1 p2))))
  (put 'mul '(polynomial polynomial)
       (lambda (p1 p2) (tag (mul-poly p1 p2))))
  (put 'mul '(polynomial polynomial)
       (lambda (p1 p2) (tag (mul-poly p1 p2))))
  (put 'mul '(polynomial number)
       (lambda (p1 p2) (tag (mul-poly-number p1 p2))))
  (put 'mul '(number polynomial)
       (lambda (p1 p2) (tag (mul-poly-number p2 p1))))
  (put 'make 'polynomial
       (lambda (var terms) (tag (make-poly var terms))))
  (define (zero?-poly p)
    (every (lambda (c) (= 0 c))
           (map coeff (term-list p)))) 
  (put 'zero? '(polynomial)
        zero?-poly)
  (define (opposite-poly p)
      (make-poly (variable p)
                 (map opposite-term (term-list p))))
  (define (sub-poly p1 p2)
    (add-poly p1
              (opposite-poly p2)))
  (put 'sub '(polynomial polynomial)
       (lambda (p1 p2) (tag (sub-poly p1 p2))))
  ; div-poly is the new function
  (define (div-poly p1 p2)
    ; TODO: check same variable
    (let ((div-terms-result (div-terms (term-list p1) (term-list p2))))
      (let ((quotient-result (car div-terms-result))
            (remainder-result (cadr div-terms-result)))
        (list
          (tag (make-poly
                 (variable p1)
                 quotient-result))
          (tag (make-poly
                 (variable p1)
                 remainder-result))))))
  (put 'div '(polynomial polynomial)
       (lambda (p1 p2) (div-poly p1 p2)))

  (define (remainder-terms a b)
    (cadr (div-terms a b)))
  ; addition from this exercise
  (define (mul-terms-by terms n)
    (map (lambda (t) (make-term 
                       (order t)
                       (* n (coeff t))))
         terms))
  (define (pow a n)
    (if (= n 0)
      1
      (* a (pow a (- n 1)))))
  (define (integerizing-factor-terms p q)
    (let ((o1 (order (car p)))
          (o2 (order (car q)))
          (c (coeff (car q))))
      (pow c (+ 1 o1 (- o2)))))
  (define (pseudoremainder-terms a b)
    (let ((i (integerizing-factor-terms a b)))
      (cadr (div-terms (mul-terms-by a i)
                       (mul-terms-by b i)))))
  (define (gcd-terms a b)
    (if (empty-termlist? b)
      a
      (gcd-terms b (pseudoremainder-terms a b))))
  (put 'gcd '(polynomial polynomial)
       (lambda (p1 p2) (tag (make-poly (variable p1)
                                       (gcd-terms (term-list p1) (term-list p2))))))
  'done)
(install-polynomial-package)
(define (install-number-package)
  (put 'zero? '(number)
    (lambda (x) (= 0 x)))
  (put 'add '(number number)
    (lambda (a b) (+ a b)))
  (put 'mul '(number number)
    (lambda (a b) (* a b)))
  (put 'div '(number number)
    (lambda (a b) (/ a b))))
(install-number-package)
; div-terms is an helper for div-poly
(define (div-terms L1 L2)
  (if (empty-termlist? L1)
	(list (the-empty-termlist) (the-empty-termlist))
	(let ((t1 (first-term L1))
		  (t2 (first-term L2)))
	  (if (> (order t2) (order t1))
		(list (the-empty-termlist) L1)
		(let ((new-c (div (coeff t1) (coeff t2)))
			  (new-o (- (order t1) (order t2))))
		  (let ((rest-of-result
            (let ((new-dividend
                    (sub-terms L1
                               (mul-terms (list (make-term new-o new-c))
                                          L2))))
                 (div-terms new-dividend
                            L2))))
			(list (cons (make-term new-o new-c)
                      (car rest-of-result))
                  (cadr rest-of-result))
			))))))
; generic operations
(define (=zero? exp)
  (apply-generic 'zero? exp))
(define (add a b)
  (apply-generic 'add a b))
(define (sub a b)
  (apply-generic 'sub a b))
(define (mul a b)
  (apply-generic 'mul a b))
(define (div a b)
  (apply-generic 'div a b))
(define (greatest-common-divisor a b)
  (apply-generic 'gcd a b))
(define (make-polynomial var terms)
  ((get 'make 'polynomial) var terms))
; examples
(define sample-numerator
  (make-polynomial 'x
                   (list (make-term 5 1)
                         (make-term 0 -1))))
(define sample-denominator
  (make-polynomial 'x
                   (list (make-term 2 1)
                         (make-term 0 -1))))
(load "/code/test-manager/load.scm")
(display sample-numerator)
(newline)
(display sample-denominator)
(newline)
(define (make-rational n d)
  ((get 'make '(rational)) n d))
(define (install-rational-package)
  (define (num r)
    (car r))
  (define (den r)
    (cadr r))
  (define (make-rat n d) (list n d))
  (define (tag value)
    (attach-tag 'rational value))
  (put 'make '(rational) (lambda (n d) (tag (make-rat n d))))
  ;(put 'zero? '(number)
  ;  (lambda (x) (= 0 x)))
  (define (simplify n d)
    (let ((the-gcd (greatest-common-divisor n d)))
      (make-rat (car (div n the-gcd))
                (car (div d the-gcd)))))
  (put 'add '(rational rational)
    (lambda (a b) (tag (simplify (add (num a) (num b))
                                 (den a)))))
  (put 'mul-both-n-d '(rational)
    (lambda (rf)
      (lambda (number) (tag (make-rat (mul (num rf) number)
                                      (mul (den rf) number)))))))
  ;(put 'mul '(number number)
  ;  (lambda (a b) (* a b)))
  ;(put 'div '(number number)
  ;  (lambda (a b) (/ a b))))
(install-rational-package)
(define (mul-both-n-d rf number)
  ((apply-generic 'mul-both-n-d rf) number))
; TODO: use gcd to reduce 'rational to lowest terms in the result of div
(display (div sample-numerator sample-denominator))
(newline)
(define x-1 (make-polynomial 'x '((1 1) (0 -1))))
(define x+1 (make-polynomial 'x '((1 1) (0 1))))
(define x^2+1 (make-polynomial 'x '((2 1) (0 1))))
(define x^3+1 (make-polynomial 'x '((3 1) (0 1))))
(define x^2-1 (make-polynomial 'x '((2 1) (0 -1))))
(define x^3-1 (make-polynomial 'x '((3 1) (0 -1))))
(define sample--x^2+x (make-polynomial 'x '((2 -1) (1 1))))
(define sample-2x^2+2x+2 (make-polynomial 'x '((2 2) (1 2) (0 2))))
(define sample-rf (make-rational x^2+1
                                 x^3+1))
(define sample1 (make-polynomial 'x '((4 1) (3 -1) (2 -2) (1 2))))
(define sample2 (make-polynomial 'x '((3 1) (1 -1))))
; this exercise
(define p1 (make-polynomial 'x
                            '((2 1) (1 -2) (0 1))))
(define p2 (make-polynomial 'x
                            '((2 11) (0 7))))
(define p3 (make-polynomial 'x
                            '((1 13) (0 5))))
(define q1 (mul p1 p2))
(define q2 (mul p1 p3))
(display "Q1: ") (display q1) (newline) ; (polynomial (x (4 11) (3 -22) (2 18) (1 -14) (0 7)))
(display "Q2: ")(display q2) (newline) ; (polynomial (x (3 13) (2 -21) (1 3) (0 5)))
; suppose we want to do q1/q2
(define c 13)
(define o1 4)
(define o2 3)
(in-test-group
  greatest-common-divisor-of-polynomials
  (define-each-test
    ; part a
    (check (equal?

             (mul p1 1458)
             ; (polynomial (x (2 1458) (1 -2916) (0 1458))) * 169
             (greatest-common-divisor q1 q2))
           "Book's corner case example. Thanks to the integerizing-factor used by pseudoremainder-terms, we get a GCD that has integer coefficients. It is however not minimal")
    ))
(run-registered-tests)
