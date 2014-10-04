#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <netdb.h>

#include "ppport.h"


static struct gaicb gcb;

MODULE = Net::DNS_A		PACKAGE = Net::DNS_A		

void
lookup(host)
    char *host
    INIT:
    int res;
    struct sigevent sev;
    struct gaicb *gptr = &gcb;
    PPCODE:
    gcb.ar_name = host;
    sev.sigev_notify = SIGEV_NONE;

    res = getaddrinfo_a(GAI_NOWAIT, &gptr, 1, &sev);
    if (res) {
        XPUSHs(sv_2mortal(newSVnv(0)));
        XPUSHs(sv_2mortal(newSVpv(gai_strerror(res), strlen(gai_strerror(res)))));
    }
    else {
        XPUSHs(sv_2mortal(newSVnv(1)));
    }

void
retrieve()
    INIT:
    int res;
    char host[NI_MAXHOST];
    struct addrinfo *ar_result;
    struct gaicb *gptr = &gcb;
    PPCODE:
    res = gai_error(&gcb);

    if (EAI_INPROGRESS == res) {
        XPUSHs(sv_2mortal(newSVnv(0)));
        XPUSHs(sv_2mortal(newSVpv("EAI_INPROGRESS",  strlen("EAI_INPROGRESS"))));
    }

    if (0 == res) {
        res = getnameinfo(gptr->ar_result->ai_addr, gptr->ar_result->ai_addrlen,
                          host, sizeof(host),
                          NULL, 0, NI_NUMERICHOST);
        if (res) {
            XPUSHs(sv_2mortal(newSVnv(0)));
            XPUSHs(sv_2mortal(newSVpv(gai_strerror(res), strlen(gai_strerror(res)))));
        }
        else {
            XPUSHs(sv_2mortal(newSVnv(1)));
            XPUSHs(sv_2mortal(newSVpv(gptr->ar_name,  strlen(gptr->ar_name))));
            XPUSHs(sv_2mortal(newSVpv(host,  strlen(host))));
        }
    }
    else {
        XPUSHs(sv_2mortal(newSVnv(0)));
        XPUSHs(sv_2mortal(newSVpv(gai_strerror(res), strlen(gai_strerror(res)))));
    }
