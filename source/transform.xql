xquery version "3.1";

import module namespace markdown = "http://exist-db.org/xquery/markdown";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";

declare variable $local:path := '/Users/stephane/Comptes/perso/virus/generateur';

declare variable $local:output := <output:serialization-parameters><output:method>html</output:method></output:serialization-parameters>;

declare variable $local:a-propos-index := 25;

declare function local:display-date ( $date as xs:string? ) {
    let $segs := tokenize($date, '-')
    let $month := 
        switch ($segs[2])
          case '01' return 'janvier'
          case '02' return 'février'
          case '03' return 'mars'
          case '04' return 'avril'
          case '05' return 'mai'
          case '06' return 'juin'
          case '07' return 'juillet'
          case '08' return 'août'
          case '09' return 'septembre'
          case '10' return 'octobre'
          case '11' return 'novembre'
          case '12' return 'décembre'
          default return $segs[2]
    return
        $segs[3] || ' ' || $month ||' ' || $segs[1]
};

declare function local:display-date-short ( $date as xs:string? ) {
    let $segs := tokenize($date, '-')
    let $month := 
        switch ($segs[2])
          case '01' return 'jan'
          case '02' return 'fév'
          case '03' return 'mars'
          case '04' return 'avril'
          case '05' return 'mai'
          case '06' return 'juin'
          case '07' return 'juillet'
          case '08' return 'août'
          case '09' return 'sept'
          case '10' return 'oct'
          case '11' return 'nov'
          case '12' return 'déc'
          default return $segs[2]
    return
        $segs[3] || ' ' || $month ||' ' || $segs[1]
};

declare function local:page-mesh ( $corps as element(), $cur as xs:integer, $all as xs:integer*, $billet as map(), $blog as map() ) {
  let $previous :=
    if ($cur gt 1) then 
      let $index := $all[$cur - 1]
      let $target := map:get($blog, $index)
      return (
        <div class="previous">
          <span>&#5130;</span>
          <p style="display:inline-block;margin-left: 5px">
            <a href="{$target?href}">{$target?shortTitle}</a><br/>
            <span style="font-size:0.75em">{local:display-date-short($target?creationDate)}</span>
          </p>           
        </div>,
        <div class="previous">
          <p>&#5130; <a href="{$target?href}">{$target?shortTitle}</a></p>
        </div>
        )
    else
      ()
  let $next := 
    if ($cur lt count($all)) then 
      let $index := $all[$cur + 1]
      let $target := map:get($blog, $index)
      return (
        <div class="next">
          <p style="display:inline-block;margin-right: 5px">
            <a href="{$target?href}">{$target?shortTitle}</a><br/>
            <span style="font-size:0.75em">{local:display-date-short($target?creationDate)}</span>
          </p>
           <span>&#5125;</span>
        </div>,        
        <div class="next">
          <p><a href="{$target?href}">{$target?shortTitle}</a> &#5125;</p>
        </div>
        )
    else
      ()
  return  
    <html lang="fr">
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
        <meta name="description" content="Blog d'un profane en réaction à la crise sanitaire et à la mise en place d'un Absurdistan hygieniste et enfermiste qui s'en suivi"/>
        <meta name="keywords" content="démocratie, absurdistan, arrêté préfectoral, covid, criste sanitaire, masque, no comment, préfecture, santé"/>
        <link href="sceptique.css" rel="stylesheet" type="text/css" />
        {
        (: Contact form seulement sur la page A propos pour le moment... :)
        if ($all[$cur] eq $local:a-propos-index)
          then <script type="text/javascript" src="site.js"/>
          else ()
        }
        <title>sceptique.fr - { $billet?shortTitle }</title>
      </head>
      <body>
        <header>
          <div id="title">
            <h1>sceptique.fr</h1>
          </div>
          <div id="about">
            <p><a href="a-propos.html">A propos</a></p>
          </div>
        </header>
        <div id="jump-top">
          { $previous[1] }
          { $next[1] }
        </div>
        <div id="main">
          <div id="down">
            <a href="#index" title="Sommaire">&#5121;</a>
          </div>        
          <div id="content">
            <h1>{ $billet?title }</h1>
            <p>{ local:display-date($billet?creationDate) } | Par { $billet?author }</p>
            {
            if (map:contains($billet, 'chapo')) then
              <blockquote class="chapo">
                <p><b>{ $billet?chapo }</b></p>
              </blockquote>
            else
              ()
            }
            { $corps }
            {
            if ($all[$cur] eq $local:a-propos-index) then
              <section>
                <h4>Nous contacter</h4>
                <form>
                  <a id="mail" style="display:none"></a>
                  <p>
                    <textarea id="comment" name="comment" rows="8" style="width:100%"></textarea>
                  </p>
                  <p>
                    <input id="submit" type="submit" onclick="javascript:ecrire(event, 'ecrire')" value="Envoyer"/>
                  </p>
                </form>
              </section>            
            else
              ()            
            }
          </div>          
          <div id="up">
            <a href="#top" title="Haut de page">&#5123;</a>
          </div>
        </div>          
        <div id="jump-bottom">
          { $previous[2] }
          { $next[2] }
        </div>
        <div id="nav">
          <div id="index">
            <h2>Sommaire</h2>
            <ul>
            {
            for $i in $all
            let $entry := map:get($blog, $i)
            where (exists($entry))
            return
              <li><a href="{$entry?href}">{$entry?shortTitle}</a></li>
            }
            </ul>
          </div>
          <div id="related">
            <h2>Pour aller plus loin</h2>
            { $blog?links/* }
          </div>
        </div>
      </body>
    </html>
};

declare function local:render-corps ( $corps as xs:string? ) {
  let $res := markdown:parse($corps)
  return
    <section>
      {
      $res/*[empty(h2[text() eq 'Bibliographie'])], 
      if (exists($res/*[h2[text() eq 'Bibliographie']])) then (
        <section id="bibliography">
            <h2>Bibliographie</h2>
            {
            for $biblio in $res//p[span]
            let $ref := $biblio/span
            let $key := '[' || $ref || ']'
            let $url := string($res//a[. eq $key]/@href)
            return 
                <p>[{string($ref)}]{$biblio/text()} (<a class="biblio" href="{$url} ">{replace($url, 'http[s]?://', '')}</a>)</p>
            }
        </section>
        )
      else
        ()
      }
  </section>
};

declare function local:render-links ( $in-path as xs:string, $file as xs:string ) {
  let $src := concat($in-path, '/', $file)
  return
    if (file:exists($src)) then 
      let $links := fn:doc('file://' || $src)/Liens
      let $corps := string-join($links/Corps/text(), '')
      return
        markdown:parse($corps)
    else
      <p><i>à venir</i></p>
};

declare function local:copy-images (  $generated as element(), $in-path as xs:string, $out-path as xs:string ) {
  string-join(
    for $img in $generated//img
    let $src := $in-path || '/' || $img/@src
    let $dest := $out-path || '/' || $img/@src
    return
      if (file:exists($dest)) then
        'exists image ' || $img/@src
      else (
        'copy image ' || $img/@src,
        file:serialize-binary(file:read-binary($src), $dest)
        )[1],
      ', '
    )
};

declare function local:post-process ( $nodes as item()* ) {
  for $node in $nodes
  return
    typeswitch($node)
      case text()
        return $node
      case attribute()
        return $node
      case element()
        return
          if (local-name($node) eq 'img') then (
            <p class="illustration">
              { $node }
            </p>,
            <p class="caption">{ string($node/@alt) }</p>
            )
          else 
            let $tag := local-name($node)
            return
              element { $tag }
                { $node/attribute(), local:post-process($node/node()) }
      default
        return $node
};

declare function local:generate-page( $cur as xs:string, $all as xs:string*, $billet as map(), $blog as map(), $in-path as xs:string, $out-path as xs:string) {
  let $generated := local:post-process(local:render-corps(string-join($billet?corps/text(), '')))
  let $page := local:page-mesh($generated, $cur, $all, $billet, $blog)
  return (
    file:serialize($page, $out-path || '/' || $billet?href, $local:output),
    local:copy-images($generated, $in-path, $out-path)
    )
};

declare function local:get-billets-list( $path as xs:string ) {
  for $i in file:list($local:path)/file:directory[matches(@name, '\d+')]/string(@name)
  (:where $i eq '25':)
  order by number($i) descending
  return $i
};

declare function local:load-blog( $all as xs:string*, $in-path ) {
  map:new(
    (
    for $cur in 1 to count($all)
    let $index := $all[$cur]
    let $src := concat($in-path, '/', $index,  '/billet.xml')
    let $billet := if (file:exists($src)) then fn:doc('file://' || $src)/Billet else ()
    where (exists($billet))
    return 
      map:entry($index,
        map:new((
          map:entry('href',
            if ($cur eq 1) then 
              'index.html'
            else
              $billet/string(@Fichier) || '.html'
            ),
          map:entry('shortTitle', $billet/string(@TitreCourt)),
          map:entry('creationDate', $billet/Meta/DateCreation),
          map:entry('author', normalize-space($billet/Meta/Auteur)),
          map:entry('title', normalize-space($billet/Titre)),
          map:entry('chapo', if ($billet/Chapo) then normalize-space($billet/Chapo) else ()),
          map:entry('corps', $billet/Corps),
          map:entry('meta', $billet/Meta)
          ))
        ),
    
    map:entry('links', local:render-links($in-path, 'source/liens.xml'))
    )
    )
};

declare function local:generate-pages( $cur as xs:integer, $all as xs:integer*, $in-path as xs:string, $out-path as xs:string) {
  let $blog := local:load-blog($all, $in-path)
  return
    for $cur in 1 to count($all)
    let $index := $all[$cur]
    let $billet := map:get($blog, $index)
    return
      if (exists($billet)) then
        <p>rendering {$billet?href} ({$index}) : { local:generate-page($cur, $all, $billet, $blog, $in-path || '/' || $index, $out-path) }</p>
      else
        <p>nothing to render at {concat($in-path, '/', $index)}</p>
};

let $billets := local:get-billets-list($local:path)
return
  <running>
    {
    local:generate-pages(1, $billets, $local:path, $local:path || '/dist')
    }
  </running>
      



