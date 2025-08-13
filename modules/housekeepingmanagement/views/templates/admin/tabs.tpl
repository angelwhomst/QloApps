<div class="panel">
    <div class="panel-heading">
        <ul class="nav nav-tabs">
            {foreach from=$tabs item=tab}
                <li class="{if $tab.active}active{/if}">
                    <a href="{$tab.url|escape:'html':'UTF-8'}">
                        {$tab.label|escape:'html':'UTF-8'}
                    </a>
                </li>
            {/foreach}
        </ul>
    </div>
    <div class="tab-content panel">
        {$content}
    </div>
</div>