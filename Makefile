PREFIX?=	/usr/local
BINDIR?=	${PREFIX}/bin

SCRIPTS= portmounts.sh

MAN=	portmounts.1

.include <bsd.prog.mk>
