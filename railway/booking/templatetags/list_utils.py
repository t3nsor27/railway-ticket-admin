from django import template

register = template.Library()

@register.filter
def index(sequence, i):
    return sequence[int(i)]

@register.filter
def li(sequence): return list(sequence)

@register.filter
def sub(n,k): return int(n)-int(k)