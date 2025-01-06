#
# Revision log:
# 14-08-2019: remove dependency on Genshi and change base url to git.haiku-os.org
# 13-06-2020: render hrevs/btrevs as ranges, so that you see all changesets involved (see #8517)
#

from trac.core import *
from trac.wiki import IWikiSyntaxProvider


class HaikuCGitReference(Component):
    implements(IWikiSyntaxProvider)

    # IWikiSyntaxProvider methods

    HAIKU_CGIT_URL = "https://git.haiku-os.org/haiku/log/?qt=range&q="
    BUILDTOOLS_CGIT_URL = "https://git.haiku-os.org/buildtools/log/?qt=range&q="

    def get_wiki_syntax(self):
        """Return an iterable that provides additional wiki syntax.

         Additional wiki syntax correspond to a pair of (regexp, cb),
        the `regexp` for the additional syntax and the callback `cb`
        which will be called if there's a match.
        That function is of the form cb(formatter, ns, match).
        """
        return (( r"(?:\b|!)r\d+\b(?!:\d)", self._format_revision_link),
                ( r"(?:\b|!)hrev\d+\b(?!:\d)", self._format_revision_link),
                ( r"(?:\b|!)btrev\d+\b(?!:\d)", self._format_revision_link))


    def get_link_resolvers(self):
        return None

    def _format_revision_link(self, formatter, text, match):
        parameters = {}
        if text[0] == "r":
            revision = int(text[1:])
            parameters["title"] =  "Haiku Revision %i" % revision
            parameters["label"] = "hrev%i" % revision
            parameters["parameters"] = "hrev%i..hrev%i" % (revision - 1, revision)
            parameters["base_url"] = self.HAIKU_CGIT_URL
        elif text.startswith("hrev"):
            revision = int(text[4:])
            parameters["title"] = "Haiku Revision %i" % revision
            parameters["label"] = text
            parameters["parameters"] = "hrev%i..hrev%i" % (revision - 1, revision)
            parameters["base_url"] = self.HAIKU_CGIT_URL
        elif text.startswith("btrev"):
            revision = int(text[5:])
            parameters["title"] = "Buildtools Revision %i" % revision
            parameters["label"] = text
            parameters["parameters"] = "btrev%i..btrev%i" % (revision - 1, revision)
            parameters["base_url"] = self.BUILDTOOLS_CGIT_URL
        else:
            return text

        return "<a class=\"changeset\" title=\"{title}\" href=\"{base_url}{parameters}\">{label}</a>".format(**parameters)

