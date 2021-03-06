; all the stuff from previous exercises...
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
  (define (tag p) (attach-tag 'polynomial p))
  (put 'add '(polynomial polynomial)
       (lambda (p1 p2) (tag (add-poly p1 p2))))
  (put 'mul '(polynomial polynomial)
       (lambda (p1 p2) (tag (mul-poly p1 p2))))
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
(newline)
(display (div sample-numerator sample-denominator))
(newline)
