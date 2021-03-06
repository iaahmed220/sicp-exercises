; forked from previous exercise (2.96)
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
                      (make-term (order term) (mul (coeff term) n)))
                    (term-list p))))
  (define (reduce-poly p1 p2)
    (if (same-variable? (variable p1) (variable p2))
      (map (lambda (terms) (make-poly (variable p1) terms))
		   (reduce-terms (term-list p1)
						 (term-list p2)))
      (error "Polys not in same var -- REDUCE-POLY"
             (list p1 p2))))
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
  (put 'reduce '(polynomial polynomial)
       (lambda (p1 p2) (map tag (reduce-poly p1 p2))))
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
  (define (reduce-by-common-factor p)
    (let ((coefficients (map coeff
                             (term-list p))))
      (contents (mul (tag p)
                     (/ 1
						(gcd-multiple-numbers coefficients))))))
  ; es1.33
  (define (gcd-integer a b)
    (if (= b 0)
      a
      (gcd-integer b (remainder a b))))
  (define (gcd-multiple-numbers numbers)
    (reduce gcd-integer (car numbers) numbers))
  (define (reduce-terms t1 t2)
	(define (take-only-quotient q-and-r)
	  (if (eq? (cadr q-and-r) '())
		(car q-and-r)
		(error "We were expecting an empty remainder to only get  the quotient, but we have both -- TAKE-ONLY-QUOTIENT" q-and-r)))

	(define (integerizing-factor-customized-for-gcd p q common-divisor)
		(let ((o1 (max (order (car p)) (order (car q))))
			  (o2 (order (car common-divisor)))
			  (c (coeff (car common-divisor))))
		  (pow c (+ 1 o1 (- o2)))))
	(let* ((common-divisor (gcd-terms t1 t2))
		   (integerizing-factor (integerizing-factor-customized-for-gcd t1 t2 common-divisor)))
		; substitute with reduced terms
		(display "common-divisor: ") (newline)
		(display common-divisor) (newline)
		(display "integerizing-factor: ") (newline)
		(display integerizing-factor) (newline)
		(let ((large-integers-intermediate-result (map (lambda (t)
			   (take-only-quotient (div-terms
									 (mul-terms-by t
												   integerizing-factor)
									 common-divisor)))
			; TODO: more pressing problem, the term list have an empty term at the end
			; TODO: we are missing the simplification of integer coefficients from t1 and t2
			 (list t1 t2))))
		  (let* ((all-coefficients
				  (reduce append
						  '()
						  (map (lambda (terms) 
								 (map coeff terms))
							   large-integers-intermediate-result)))
				(gcd-coefficients (gcd-multiple-numbers all-coefficients)))
				(display "all-coefficients: ")
			  (display all-coefficients)
			  (newline)
			  (map (lambda (terms) (mul-terms-by terms (/ 1 gcd-coefficients)))
				   large-integers-intermediate-result)))))
  (put 'gcd '(polynomial polynomial)
       (lambda (p1 p2)
         (tag 
           (let ((not-reduced-result
                   (make-poly (variable p1)
                              (gcd-terms (term-list p1) 
                                         (term-list p2)))))
             (reduce-by-common-factor not-reduced-result)))))
  'done)
(install-polynomial-package)
(define (install-number-package)
  (define (gcd-integer a b)
    (if (= b 0)
      a
      (gcd-integer b (remainder a b))))
  (define (reduce-integers n d)
	(let ((g (gcd-integer n d)))
	  (list (/ n g) (/ d g))))
  (put 'zero? '(number)
    (lambda (x) (= 0 x)))
  (put 'add '(number number)
    (lambda (a b) (+ a b)))
  (put 'mul '(number number)
    (lambda (a b) (* a b)))
  (put 'div '(number number)
    (lambda (a b) (/ a b)))
  (put 'reduce '(number number)
    (lambda (a b) (reduce-integers a b))))
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
(define (reduce-generic a b)
  (apply-generic 'reduce a b))
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
	(display "simplify: ")
    (let ((the-gcd (greatest-common-divisor n d)))
      (make-rat (car (div n the-gcd))
                (car (div d the-gcd)))))
  (put 'add
       '(rational rational)
       (lambda (a b)
         (let ((result-numerator 
                 (add (mul (num a)
                           (den b))
                      (mul (num b)
                           (den a))))
               (result-denominator (mul (den a) (den b))))
           (tag (simplify result-numerator
                          result-denominator)))))
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
; from previous exercise
(define old-p1 (make-polynomial 'x
                            '((2 1) (1 -2) (0 1))))
(define old-p2 (make-polynomial 'x
                            '((2 11) (0 7))))
(define old-p3 (make-polynomial 'x
                            '((1 13) (0 5))))
(define old-q1 (mul old-p1 old-p2)) ; (polynomial (x (4 11) (3 -22) (2 18) (1 -14) (0 7)))
(define old-q2 (mul old-p1 old-p3)) ; (polynomial (x (3 13) (2 -21) (1 3) (0 5)))
; this exercise
(define p1 (make-polynomial 'x '((1 1) (0 1))))
(define p2 (make-polynomial 'x '((3 1) (0 -1))))
(define p3 (make-polynomial 'x '((1 1))))
(define p4 (make-polynomial 'x '((2 1) (0 -1))))
(define rf1 (make-rational p1 p2))
(define rf2 (make-rational p3 p4))
(in-test-group
  reduce-generic-operation
  (define-each-test
    (check (equal? 
             (list 3 4)
             (reduce-generic 30 40))
           "Two integers with a common factor")
    (check (equal? 
			 (list old-p2 old-p3)
             (reduce-generic old-q1 old-q2))
           "Two polynomials with a common divisor")
	))
; TODO: uncomment and make this test pass
; you'll have to use the new reduce-generic inside make-rat
(define x+1 (make-polynomial 'x '((1 1) (0 1))))
(define x-1 (make-polynomial 'x '((1 1) (0 -1))))
(define x^2-1 (make-polynomial 'x '((2 1) (0 -1))))
(define poly-2x+2 (make-polynomial 'x '((1 2) (0 2))))
(define poly-2x^2+2 (make-polynomial 'x '((2 2) (0 2))))
(in-test-group
  reducing-rational-functions-during-addition
  (define-each-test
    (check (equal? 
			 (make-rational poly-2x+2 x-1)
             (add 
                 (make-rational x+1 x-1)
                 (make-rational x+1 x-1)))
           "Result of addition, base case")
    (check (equal? 
             ; numerator (x^2+2x+1)+(x^2-2x+1)
             ; denominator: (x+1)(x-1)
			 (make-rational poly-2x^2+2 x^2-1)
             (add 
                 (make-rational x+1 x-1)
                 (make-rational x-1 x+1)))
           "Result of addition, different denominators")
    (check (equal? 
             ; equivalent to the result of https://wizardbook.wordpress.com/2010/12/14/exercise-2-97/
    		 (make-rational (make-polynomial 'x '((3 1) (2 2) (1 3) (0 1)))
                            (make-polynomial 'x '((4 1) (3 1) (1 -1) (0 -1))))
             ; p2 and p4, the denominators, have order 3 and 2
             ; so without simplifications you would expect a order 5 denominator
             ; instead, we get a order 4 because there is a common factor x-1 in them
             (add rf1 rf2))
           "Result of addition should be simplified")
    ))
(run-registered-tests)
