# -*- coding: utf-8 -*-
"""
Manin symbols

This module defines the class ManinSymbol.  A Manin symbol of
weight `k`, level `N` has the form `[P(X,Y),(u:v)]` where
`P(X,Y)\in\mathbb{Z}[X,Y]` is homogeneous of weight `k-2` and
`(u:v)\in\mathbb{P}^1(\mathbb{Z}/N\mathbb{Z}).`  The ManinSymbol class
holds a "monomial Manin symbol" of the simpler form
`[X^iY^{k-2-i},(u:v)]`, which is stored as a triple `(i,u,v)`; the
weight and level are obtained from the parent structure, which is a
:class:`sage.modular.modsym.manin_symbol_list.ManinSymbolList`.

Integer matrices `[a,b;c,d]` act on Manin symbols on the right,
sending `[P(X,Y),(u,v)]` to `[P(aX+bY,cX+dY),(u,v)g]`.  Diagonal
matrices (with `b=c=0`, such as `I=[-1,0;0,1]` and `J=[-1,0;0,-1]`)
and anti-diagonal matrices (with `a=d=0`, such as `S=[0,-1;1,0]`) map
monomial Manin symbols to monomial Manin symbols, up to a scalar
factor.  For general matrices (such as `T=[0,1,-1,-1]` and
`T^2=[-1,-1;0,1]`) the image of a monomial Manin symbol is expressed
as a formal sum of monomial Manin symbols, with integer coefficients.

"""

from sage.modular.cusps import Cusp
from sage.rings.all import Infinity, ZZ
from sage.rings.integer cimport Integer
from sage.structure.element cimport Element
from sage.structure.sage_object import register_unpickle_override


def is_ManinSymbol(x):
    """
    Return ``True`` if ``x`` is a :class:`ManinSymbol`.

    EXAMPLES::

        sage: from sage.modular.modsym.manin_symbol import ManinSymbol, is_ManinSymbol
        sage: from sage.modular.modsym.manin_symbol_list import ManinSymbolList_gamma0
        sage: m = ManinSymbolList_gamma0(6, 4)
        sage: s = ManinSymbol(m, m.symbol_list()[3])
        sage: s
        [Y^2,(1,2)]
        sage: is_ManinSymbol(s)
        True
        sage: is_ManinSymbol(m[3])
        True
    """
    return isinstance(x, ManinSymbol)


cdef class ManinSymbol(Element):
    r"""
    A Manin symbol `[X^i Y^{k-2-i}, (u, v)]`.

    INPUT:

    - ``parent`` -- :class:`~sage.modular.modsym.manin_symbol_list.ManinSymbolList`

    - ``t`` -- a triple `(i, u, v)` of integers

    EXAMPLES::

        sage: from sage.modular.modsym.manin_symbol import ManinSymbol
        sage: from sage.modular.modsym.manin_symbol_list import ManinSymbolList_gamma0
        sage: m = ManinSymbolList_gamma0(5,2)
        sage: s = ManinSymbol(m,(2,2,3)); s
        (2,3)
        sage: s == loads(dumps(s))
        True

    ::

        sage: m = ManinSymbolList_gamma0(5,8)
        sage: s = ManinSymbol(m,(2,2,3)); s
        [X^2*Y^4,(2,3)]

    ::

        sage: from sage.modular.modsym.manin_symbol import ManinSymbol
        sage: from sage.modular.modsym.manin_symbol_list import ManinSymbolList_gamma0
        sage: m = ManinSymbolList_gamma0(5,8)
        sage: s = ManinSymbol(m,(2,2,3))
        sage: s.parent()
        Manin Symbol List of weight 8 for Gamma0(5)

    """
    def __init__(self, parent, t):
        r"""
        Create a Manin symbol `[X^i Y^{k-2-i}, (u, v)]`, where
        `k` is the weight.

        INPUT:

        - ``parent`` -- :class:`~sage.modular.modsym.manin_symbol_list.ManinSymbolList`

        - ``t`` -- a triple `(i, u, v)` of integers

        EXAMPLES::

            sage: from sage.modular.modsym.manin_symbol import ManinSymbol
            sage: from sage.modular.modsym.manin_symbol_list import ManinSymbolList_gamma0
            sage: m = ManinSymbolList_gamma0(5,2)
            sage: s = ManinSymbol(m,(2,2,3)); s
            (2,3)

        ::

            sage: m = ManinSymbolList_gamma0(5,8)
            sage: s = ManinSymbol(m,(2,2,3)); s
            [X^2*Y^4,(2,3)]

        """
        self.__t = t
        Element.__init__(self, parent)

    def __reduce__(self):
        """
        For pickling.

        TESTS::

            sage: from sage.modular.modsym.manin_symbol import ManinSymbol
            sage: from sage.modular.modsym.manin_symbol_list import ManinSymbolList_gamma1
            sage: m = ManinSymbolList_gamma1(3, 2)
            sage: s = ManinSymbol(m, (2, 2, 3))
            sage: loads(dumps(s))
            (2,3)

        """
        return ManinSymbol, (self.parent(), self.__t)

    def __setstate__(self, state):
        """
        Needed to unpickle old :class:`ManinSymbol` objects.

        TESTS::

            sage: from sage.modular.modsym.manin_symbol import ManinSymbol
            sage: from sage.modular.modsym.manin_symbol_list import ManinSymbolList_gamma0
            sage: m = ManinSymbolList_gamma0(5,2)
            sage: s = ManinSymbol(m,(2,2,3))
            sage: loads(dumps(s))
            (2,3)

        """
        self._parent = state['_ManinSymbol__parent']
        self.__t = state['_ManinSymbol__t']

    def tuple(self):
        r"""
        Return the 3-tuple `(i,u,v)` of this Manin symbol.

        EXAMPLES::

            sage: from sage.modular.modsym.manin_symbol import ManinSymbol
            sage: from sage.modular.modsym.manin_symbol_list import ManinSymbolList_gamma0
            sage: m = ManinSymbolList_gamma0(5,8)
            sage: s = ManinSymbol(m,(2,2,3))
            sage: s.tuple()
            (2, 2, 3)

        """
        return self.__t

    def __get_i(self):
        """
        Return the `i` field of this Manin symbol `(i,u,v)`.

        EXAMPLES::

            sage: from sage.modular.modsym.manin_symbol import ManinSymbol
            sage: from sage.modular.modsym.manin_symbol_list import ManinSymbolList_gamma0
            sage: m = ManinSymbolList_gamma0(5,8)
            sage: s = ManinSymbol(m,(2,2,3))
            sage: s.__get_i()
            2
            sage: s.i
            2
        """
        return self.__t[0]

    i = property(__get_i)

    def __get_u(self):
        """
        Return the `u` field of this Manin symbol `(i,u,v)`.

        EXAMPLES::

            sage: from sage.modular.modsym.manin_symbol import ManinSymbol
            sage: from sage.modular.modsym.manin_symbol_list import ManinSymbolList_gamma0
            sage: m = ManinSymbolList_gamma0(5,8)
            sage: s = ManinSymbol(m,(2,2,3))
            sage: s.u # indirect doctest
            2
        """
        return self.__t[1]

    u = property(__get_u)

    def __get_v(self):
        """
        Return the `v` field of this Manin symbol `(i,u,v)`.

        EXAMPLES::

            sage: from sage.modular.modsym.manin_symbol import ManinSymbol
            sage: from sage.modular.modsym.manin_symbol_list import ManinSymbolList_gamma0
            sage: m = ManinSymbolList_gamma0(5,8)
            sage: s = ManinSymbol(m,(2,2,3))
            sage: s.v # indirect doctest
            3
        """
        return self.__t[2]
    v = property(__get_v)

    def _repr_(self):
        """
        Return a string representation of this Manin symbol.

        EXAMPLES::

            sage: from sage.modular.modsym.manin_symbol import ManinSymbol
            sage: from sage.modular.modsym.manin_symbol_list import ManinSymbolList_gamma0
            sage: m = ManinSymbolList_gamma0(5,8)
            sage: s = ManinSymbol(m,(2,2,3))
            sage: str(s)  # indirect doctest
            '[X^2*Y^4,(2,3)]'
        """
        if self.weight() > 2:
            polypart = _print_polypart(self.i, self.weight()-2-self.i)
            return "[%s,(%s,%s)]"%\
                   (polypart, self.u, self.v)
        return "(%s,%s)"%(self.u, self.v)

    def _latex_(self):
        """
        Return a LaTeX representation of this Manin symbol.

        EXAMPLES::

            sage: from sage.modular.modsym.manin_symbol import ManinSymbol
            sage: from sage.modular.modsym.manin_symbol_list import ManinSymbolList_gamma0
            sage: m = ManinSymbolList_gamma0(5,8)
            sage: s = ManinSymbol(m,(2,2,3))
            sage: latex(s) # indirect doctest
            [X^2*Y^4,(2,3)]
        """
        return self._repr_()

    def __cmp__(self, other):
        """
        Comparison function for ManinSymbols.

        EXAMPLES::

            sage: from sage.modular.modsym.manin_symbol import ManinSymbol
            sage: from sage.modular.modsym.manin_symbol_list import ManinSymbolList_gamma0
            sage: m = ManinSymbolList_gamma0(5,8)
            sage: slist = m.manin_symbol_list()
            sage: cmp(slist[10],slist[20])
            -1
            sage: cmp(slist[20],slist[10])
            1
            sage: cmp(slist[20],slist[20])
            0
        """
        if not isinstance(other, ManinSymbol):
            return -1
        return cmp(self.tuple(), other.tuple())

    def __mul__(self, matrix):
        """
        Return the result of applying a matrix to this Manin symbol.

        EXAMPLES::

            sage: from sage.modular.modsym.manin_symbol import ManinSymbol
            sage: from sage.modular.modsym.manin_symbol_list import ManinSymbolList_gamma0
            sage: m = ManinSymbolList_gamma0(5,2)
            sage: s = ManinSymbol(m,(0,2,3))
            sage: s*[1,2,0,1]
            (2,7)

        ::

            sage: m = ManinSymbolList_gamma0(5,8)
            sage: s = ManinSymbol(m,(2,2,3))
            sage: s*[1,2,0,1]
            Traceback (most recent call last):
            ...
            NotImplementedError: ModSym * Matrix only implemented in weight 2
        """
        if self.weight() > 2:
            raise NotImplementedError("ModSym * Matrix only implemented "
                                      "in weight 2")
        from sage.matrix.matrix import is_Matrix
        if is_Matrix(matrix):
            if (not matrix.nrows() == 2) or (not matrix.ncols() == 2):
                raise ValueError("matrix(=%s) must be 2x2" % matrix)
            matrix = matrix.list()
        return self.__class__(self.parent(),
                              (self.i,
                               matrix[0]*self.u + matrix[2]*self.v,
                               matrix[1]*self.u + matrix[3]*self.v))

    def apply(self, a,b,c,d):
        """
        Return the image of self under the matrix `[a,b;c,d]`.

        Not implemented for raw ManinSymbol objects, only for members
        of ManinSymbolLists.

        EXAMPLE::

            sage: from sage.modular.modsym.manin_symbol import ManinSymbol
            sage: from sage.modular.modsym.manin_symbol_list import ManinSymbolList_gamma0
            sage: m = ManinSymbolList_gamma0(5,2)
            sage: m.apply(10,[1,0,0,1]) # not implemented for base class
        """
        raise NotImplementedError

    def __copy__(self):
        """
        Return a copy of this Manin symbol.

        EXAMPLES::

            sage: from sage.modular.modsym.manin_symbol import ManinSymbol
            sage: from sage.modular.modsym.manin_symbol_list import ManinSymbolList_gamma0
            sage: m = ManinSymbolList_gamma0(5,8)
            sage: s = ManinSymbol(m,(2,2,3))
            sage: s2 = copy(s)
            sage: s2
            [X^2*Y^4,(2,3)]
        """
        return self.__class__(self.parent(), (self.i, self.u, self.v))

    def lift_to_sl2z(self, N=None):
        r"""
        Return a lift of this Manin symbol to `SL_2(\mathbb{Z})`.

        If this Manin symbol is `(c,d)` and `N` is its level, this
        function returns a list `[a,b, c',d']` that defines a 2x2
        matrix with determinant 1 and integer entries, such that
        `c=c'` (mod `N`) and `d=d'` (mod `N`).

        EXAMPLES::

            sage: from sage.modular.modsym.manin_symbol import ManinSymbol
            sage: from sage.modular.modsym.manin_symbol_list import ManinSymbolList_gamma0
            sage: m = ManinSymbolList_gamma0(5,8)
            sage: s = ManinSymbol(m,(2,2,3))
            sage: s
            [X^2*Y^4,(2,3)]
            sage: s.lift_to_sl2z()
            [1, 1, 2, 3]

        """
        if N is None:
            N = self.level()
        if N == 1:
            return [ZZ.one(), ZZ.zero(), ZZ.zero(), ZZ.one()]
        c = Integer(self.u)
        d = Integer(self.v)
        g, z1, z2 = c.xgcd(d)

        # We're lucky: z1*c + z2*d = 1.
        if g==1:
            return [z2, -z1, c, d]

        # Have to try harder.
        if c == 0:
            c += N
        if d == 0:
            d += N
        m = c

        # compute prime-to-d part of m.
        while True:
            g = m.gcd(d)
            if g == 1:
                break
            m //= g

        # compute prime-to-N part of m.
        while True:
            g = m.gcd(N)
            if g == 1:
                break
            m //= g
        d += N*m
        g, z1, z2 = c.xgcd(d)
        assert g==1
        return [z2, -z1, c, d]

    def endpoints(self, N=None):
        r"""
        Return cusps `alpha`, `beta` such that this Manin symbol, viewed as a
        symbol for level `N`, is `X^i*Y^{k-2-i} \{alpha, beta\}`.

        EXAMPLES::

            sage: from sage.modular.modsym.manin_symbol import ManinSymbol
            sage: from sage.modular.modsym.manin_symbol_list import ManinSymbolList_gamma0
            sage: m = ManinSymbolList_gamma0(5,8)
            sage: s = ManinSymbol(m,(2,2,3)); s
            [X^2*Y^4,(2,3)]
            sage: s.endpoints()
            (1/3, 1/2)
        """
        if N is None:
            N = self.parent().level()
        else:
            N=int(N)
            if N < 1:
                raise ArithmeticError("N must be positive")
        a,b,c,d = self.lift_to_sl2z()
        return Cusp(b, d), Cusp(a, c)

    def weight(self):
        """
        Return the weight of this Manin symbol.

        EXAMPLES::

            sage: from sage.modular.modsym.manin_symbol import ManinSymbol
            sage: from sage.modular.modsym.manin_symbol_list import ManinSymbolList_gamma0
            sage: m = ManinSymbolList_gamma0(5,8)
            sage: s = ManinSymbol(m,(2,2,3))
            sage: s.weight()
            8

        """
        return self.parent().weight()

    def level(self):
        """
        Return the level of this Manin symbol.

        EXAMPLES::

            sage: from sage.modular.modsym.manin_symbol import ManinSymbol
            sage: from sage.modular.modsym.manin_symbol_list import ManinSymbolList_gamma0
            sage: m = ManinSymbolList_gamma0(5,8)
            sage: s = ManinSymbol(m,(2,2,3))
            sage: s.level()
            5

        """
        return self.parent().level()

    def modular_symbol_rep(self):
        """
        Return a representation of ``self`` as a formal sum of modular
        symbols.

        The result is not cached.

        EXAMPLES::

            sage: from sage.modular.modsym.manin_symbol import ManinSymbol
            sage: from sage.modular.modsym.manin_symbol_list import ManinSymbolList_gamma0
            sage: m = ManinSymbolList_gamma0(5,8)
            sage: s = ManinSymbol(m,(2,2,3))
            sage: s.modular_symbol_rep()
             144*X^6*{1/3, 1/2} - 384*X^5*Y*{1/3, 1/2} + 424*X^4*Y^2*{1/3, 1/2} - 248*X^3*Y^3*{1/3, 1/2} + 81*X^2*Y^4*{1/3, 1/2} - 14*X*Y^5*{1/3, 1/2} + Y^6*{1/3, 1/2}


        """
        # TODO: It would likely be much better to do this slightly more directly
        from sage.modular.modsym.modular_symbols import ModularSymbol
        x = ModularSymbol(self.parent(), self.i, 0, Infinity)
        a,b,c,d = self.lift_to_sl2z()
        return x.apply([a,b,c,d])


def _print_polypart(i, j):
    r"""
    Helper function for printing the polynomial part `X^iY^j` of a ManinSymbol.

    EXAMPLES::

    sage: from sage.modular.modsym.manin_symbol import _print_polypart
    sage: _print_polypart(2,3)
    'X^2*Y^3'
    sage: _print_polypart(2,0)
    'X^2'
    sage: _print_polypart(0,1)
    'Y'
    """
    if i > 1:
        xpart = "X^%s"%i
    elif i == 1:
        xpart = "X"
    else:
        xpart = ""
    if j > 1:
        ypart = "Y^%s"%j
    elif j == 1:
        ypart = "Y"
    else:
        ypart = ""
    if len(xpart) > 0 and len(ypart) > 0:
        times = "*"
    else:
        times = ""
    if len(xpart + ypart) > 0:
        polypart = "%s%s%s"%(xpart, times, ypart)
    else:
        polypart = ""
    return polypart


register_unpickle_override('sage.modular.modsym.manin_symbols',
                           'ManinSymbol', ManinSymbol)
