{extends file='layout.tpl'}

{block name='content'}
    <div class="panel">
        <h3>{l s='Housekeeping Tasks' mod='housekeepingmanagement'}</h3>

        {if $list}
            <table class="table table-bordered table-hover">
                <thead>
                    <tr>
                        <th>{$fields_list.id_task.title}</th>
                        <th>{$fields_list.task_name.title}</th>
                        <th>{$fields_list.status.title}</th>
                    </tr>
                </thead>
                <tbody>
                    {foreach from=$list item=task}
                        <tr>
                            <td>{$task.id_task}</td>
                            <td>{$task.task_name}</td>
                            <td>{$task.status}</td>
                        </tr>
                    {/foreach}
                </tbody>
            </table>

            {* Pagination and other helper elements can be added here *}
        {else}
            <p>{l s='No housekeeping tasks found.' mod='housekeepingmanagement'}</p>
        {/if}
    </div>
{/block}
