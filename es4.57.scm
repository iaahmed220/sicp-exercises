(rule (can-replace ?p1 ?p2)
      (and ((or ((and (job ?p1 ?j1)
                      (job ?p2 ?j1)))
                ((and (job ?p1 ?j1)
                      (job ?p2 ?j2)
                      (can-do-job ?j1 ?j2)))))
           (not (same ?p1 ?p2))))

(can-replace ?p (Fect Cy D.))
(and (can-replace ?p ?p-paid-more)
     (salary ?p ?s)
     (salary ?p-paid-more ?s-more)
     (lisp-value (> ?s-more s)))