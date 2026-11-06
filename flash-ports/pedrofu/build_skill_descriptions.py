"""Generate Pedro's original live skill descriptions, with CE key labels.

The text and arithmetic come from recovered SkillDef.as. Fractions are kept
exact until the original Str/int conversion, then truncated to hundredths.
This intentionally does not copy floating-point roundoff from Flash Number.
"""
from pathlib import Path
from fractions import Fraction
import ast, json, math, re

HERE = Path(__file__).resolve().parent
SOURCE = HERE / 'original/scripts/xplor/Menus/SkillDef.as'
original = SOURCE.read_text()
ids = dict((name, int(value)) for name, value in
           re.findall(r'public static const (\w+):uint = (\d+)', original))
functions = {}
numeric_bounds = []
for match in re.finditer(r'public static function (\w+)\([^)]*\)\s*:\s*Number\s*\{', original):
    start = end = match.end(); depth = 1
    while depth:
        depth += (original[end] == '{') - (original[end] == '}'); end += 1
    body = original[start:end]
    default = re.search(r'pts = int\(Profile.skills\[(?:SkillDef\.)?(\w+)\]\)', body)
    functions[match[1]] = (re.findall(r'return ([^;]+);', body)[-1],
                           'skills[%d]' % ids[default[1]] if default else '-1')


def terms(text):
    quote = escaped = False; depth = 0; start = 0; result = []
    for i, char in enumerate(text):
        if escaped: escaped = False; continue
        if char == '\\' and quote: escaped = True; continue
        if char == '"': quote = not quote
        if quote: continue
        if char == '(': depth += 1
        if char == ')': depth -= 1
        if char == '+' and not depth: result.append(text[start:i].strip()); start = i + 1
    return result + [text[start:].strip()]


def expr(source, pts='pts'):
    source = re.sub(r'Profile.skills\[(?:SkillDef\.)?(\w+)\]',
                    lambda m: 'skills[%d]' % ids[m[1]], source)

    def visit(node):
        if isinstance(node, ast.Constant):
            number = Fraction(str(node.value)); return str(number.numerator), number.denominator
        if isinstance(node, ast.Name) and node.id == 'pts': return pts, 1
        if isinstance(node, ast.Subscript) and isinstance(node.value, ast.Name) and node.value.id == 'skills':
            return 'progress.skills[%d]' % node.slice.value, 1
        if isinstance(node, ast.UnaryOp) and isinstance(node.op, ast.USub):
            numerator, denominator = visit(node.operand); return '(-%s)' % numerator, denominator
        if isinstance(node, ast.BinOp):
            left, ld = visit(node.left); right, rd = visit(node.right)
            if isinstance(node.op, ast.Mult): return '(%s*%s)' % (left, right), ld * rd
            if isinstance(node.op, (ast.Add, ast.Sub)):
                denominator = math.lcm(ld, rd)
                if denominator != ld: left = '(%s*%d)' % (left, denominator // ld)
                if denominator != rd: right = '(%s*%d)' % (right, denominator // rd)
                return '(%s%s%s)' % (left, '+' if isinstance(node.op, ast.Add) else '-', right), denominator
        if isinstance(node, ast.Call) and isinstance(node.func, ast.Name) and node.func.id in functions:
            formula, default = functions[node.func.id]
            if node.args:
                argument, denominator = visit(node.args[0]); assert denominator == 1
            else: argument = expr(default, pts)[0]
            return expr(formula, argument)
        raise ValueError(ast.dump(node))
    return visit(ast.parse(source, mode='eval').body)


def integer(source, scale=1):
    numerator, denominator = expr(source)
    # Reduce the final scale before evaluating to avoid unnecessary wide math.
    common = math.gcd(scale, denominator); scale //= common; denominator //= common
    if scale != 1: numerator = '(%s*%d)' % (numerator, scale)
    result = numerator if denominator == 1 else '(%s/%d)' % (numerator, denominator)
    def interval(node):
        if isinstance(node,ast.Constant): low=high=node.value
        elif isinstance(node,ast.Name) and node.id=='pts': low,high=1,5
        elif isinstance(node,ast.Subscript): low,high=0,5
        elif isinstance(node,ast.UnaryOp) and isinstance(node.op,ast.USub):
            a,b=interval(node.operand);low,high=-b,-a
        elif isinstance(node,ast.BinOp):
            a,b=interval(node.left);c,d=interval(node.right)
            if isinstance(node.op,ast.Add):low,high=a+c,b+d
            elif isinstance(node.op,ast.Sub):low,high=a-d,b-c
            elif isinstance(node.op,ast.Mult):
                values=[a*c,a*d,b*c,b*d];low,high=min(values),max(values)
            elif isinstance(node.op,ast.Div):
                assert c==d and c>0 and a>=0
                low,high=a//c,b//c
            else:raise ValueError(ast.dump(node))
        else:raise ValueError(ast.dump(node))
        assert -8388608<=low<=high<=8388607,(result,low,high)
        numeric_bounds.append((low,high));return low,high
    interval(ast.parse(result,mode='eval').body)
    return result


cases = re.findall(r'case (\w+):\s*return (.*?);', original, re.S)
assert len(cases) == 45 and len({ids[name] for name, _ in cases}) == 45
lines = ['/* Generated from original SkillDef.Describe. X/C labels become ALPHA/DEL.',
         ' * Arithmetic uses exact fractions truncated to hundredths, not Flash roundoff. */',
         '#ifndef PEDRO_SKILL_DESCRIPTIONS_H', '#define PEDRO_SKILL_DESCRIPTIONS_H',
         'static const char *sd_number(int value,char *buffer){',
         ' snprintf(buffer,16,"%d.%02d",value/100,value%100);',
         ' unsigned n=strlen(buffer);while(n&&buffer[n-1]==\'0\')buffer[--n]=0;',
         ' if(n&&buffer[n-1]==\'.\')buffer[--n]=0;return buffer;',
         '}',
         'static void skill_description(int id,int pts,char *dest,unsigned capacity){',
         ' char number[4][16];(void)number;if(!capacity)return;',
         ' if(pts<1)pts=1;if(pts>5)pts=5;', ' switch(id){']
metadata = []
for name, source in cases:
    format_text = ''; args = []; count = 0
    for term in terms(source):
        if term.startswith('"'):
            value = json.loads(term.replace("\\'", "'"))
            value = re.sub(r'\bX\b', 'ALPHA', value)
            value = re.sub(r'\bC\b', 'DEL', value)
            format_text += value.replace('%', '%%')
        elif term.startswith('Str('):
            end = term.rfind(')')
            inner = term[4:end]
            if inner.endswith(').toString('): inner = inner[:-12]
            # A single source case writes Str(...).toString(), a no-op in AS3.
            if term.endswith('.toString()'): inner = term[4:-12]
            args.append('sd_number(%s,number[%d])' % (integer(inner, 100), count))
            count += 1; format_text += '%s'
        elif term.startswith('int('):
            inner = term[4:-12] if term.endswith('.toString()') else term[4:-1]
            args.append(integer(inner)); format_text += '%d'
        else: raise ValueError(term)
    assert count <= 4
    lines += [' case %d:snprintf(dest,capacity,%s%s);break;' %
              (ids[name], json.dumps(format_text), ',' + ','.join(args) if args else '')]
    metadata.append(dict(id=ids[name], name=name, original_expression=source,
                         substitutions={'X': 'ALPHA', 'C': 'DEL'}))
bound=max(max(abs(a),abs(b))for a,b in numeric_bounds)
lines += [' default:dest[0]=0;break;', ' }', '}',
          '/* Interval audit: all ranks1..5, modifier ranks0..5; every generated',
          ' * integer subexpression has absolute value <= %d (signed24-bit safe). */'%bound,
          '#endif', '']
(HERE / 'src/skill_descriptions.h').write_text('\n'.join(lines))
print('Generated', len(cases), 'live original skill descriptions; integer intermediate bound',bound)
