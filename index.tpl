{**
 * plugins/importexport/quickSubmit/index.tpl
 *
 * Copyright (c) 2013-2016 Simon Fraser University Library
 * Copyright (c) 2003-2016 John Willinsky
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 * Template for one-page submission form
 *
 *}
{strip}
{assign var="pageTitle" value="plugins.importexport.quickSubmit.displayName"}
{include file="common/header.tpl"}
{/strip}
<script src="{$baseUrl}/plugins/importexport/quickSubmit/js/QuickSubmitFormHandler.js"></script>

<script>
	$(function() {ldelim}
		// Attach the form handler.
		//$('#quickSubmitForm').pkpHandler('$.pkp.plugins.importexport.quickSubmit.js.QuickSubmitFormHandler');

		$('#uploadImageForm').pkpHandler(
		//$('#quickSubmitForm').pkpHandler(
			'$.pkp.controllers.form.FileUploadFormHandler',
			{ldelim}
				$uploader: $('#coverImageUploader'),
				$preview: $('#coverImagePreview'),
				uploaderOptions: {ldelim}
					uploadUrl: {plugin_url|json_encode path="uploadCoverImage" escape=false},
					baseUrl: {$baseUrl|json_encode},
					filters: {ldelim}
						mime_types : [
							{ldelim} title : "Image files", extensions : "jpg,jpeg,png" {rdelim}
						]
					{rdelim},
					multipart_params: {ldelim}
						submissionId: {$submissionId|escape},
						stageId: {$stageId},
					{rdelim}
				{rdelim}
			{rdelim}
		);

		$('#quickSubmitForm').pkpHandler('$.pkp.plugins.importexport.quickSubmit.js.QuickSubmitFormHandler');
	{rdelim});
	
</script>

<div id="quickSubmitPlugin" class="pkp_page_content pkp_pageQuickSubmit"> 
	<p>{translate key="plugins.importexport.quickSubmit.descriptionLong"}</p>

	<form class="pkp_form" id="uploadImageForm" method="post">
		{fbvFormArea id="coverImage" title="editor.issues.coverPage"}
			{fbvFormSection}
				{include file="controllers/fileUploadContainer.tpl" id="coverImageUploader"}
				<input type="hidden" name="temporaryFileId" id="temporaryFileId" value="" />
			{/fbvFormSection}
			{fbvFormSection id="coverImagePreview"}
				{if $coverImage != ''}
					<div class="pkp_form_file_view pkp_form_image_view">
						<div class="img">
							<img src="{$publicFilesDir}/{$coverImage|escape:"url"}{'?'|uniqid}" {if $coverImageAlt !== ''} alt="{$coverImageAlt|escape}"{/if}>
						</div>

						<div class="data">
							<span class="title">
								{translate key="common.altText"}
							</span>
							<span class="value">
								{fbvElement type="text" id="coverImageAltText" label="common.altTextInstructions" value=$coverImageAltText}
							</span>

							<div id="{$deleteCoverImageLinkAction->getId()}" class="actions">
								{include file="linkAction/linkAction.tpl" action=$deleteCoverImageLinkAction contextId="issueForm"}
							</div>
						</div>
					</div>
				{/if}
			{/fbvFormSection}
		{/fbvFormArea}
	</form> 
	<form class="pkp_form" id="quickSubmitForm" method="post" action="{plugin_url path="saveSubmit"}">
		{if $submissionId}<input type="hidden" name="submissionId" value="{$submissionId|escape}"/>{/if}

		{csrf}
		{include file="controllers/notification/inPlaceNotification.tpl" notificationId="quickSubmitFormNotification"}

		{if $hasIssues}
			{fbvFormSection id='articlePublishedRadio' list="true"}
				{fbvElement type="radio" id="articleUnpublished" name="articleStatus" value=0 checked=$articleStatus|compare:false label='plugins.importexport.quickSubmit.unpublished' translate="true"}
				{fbvElement type="radio" id="articlePublished" name="articleStatus" value=1 checked=$articleStatus|compare:true label='plugins.importexport.quickSubmit.published' translate="true"}

				<div id="schedulePublicationDiv" class="">
					<ul class="">
						<li>{include file="linkAction/linkAction.tpl" action=$schedulePublicationLinkAction}</li>
					</ul>
				</div>
			{/fbvFormSection}
		{/if}

		{* There is only one supported submission locale; choose it invisibly *}
		{if count($supportedSubmissionLocaleNames) == 1}
			{foreach from=$supportedSubmissionLocaleNames item=localeName key=locale}
				{fbvElement type="hidden" id="locale" value=$locale}
			{/foreach}

		{* There are several submission locales available; allow choice *}
		{else}
			{fbvFormSection title="submission.submit.submissionLocale" size=$fbvStyles.size.MEDIUM for="locale"}
				{fbvElement label="submission.submit.submissionLocaleDescription" required="true" type="select" id="locale" from=$supportedSubmissionLocaleNames selected=$locale translate=false}
			{/fbvFormSection}
		{/if}

		{include file="submission/form/section.tpl" readOnly=$formParams.readOnly}

		{include file="core:submission/submissionMetadataFormTitleFields.tpl"}
		{include file="submission/submissionMetadataFormFields.tpl"}


		{fbvFormArea id="contributors"}
			<!--  Contributors -->
			{url|assign:authorGridUrl router=$smarty.const.ROUTE_COMPONENT component="grid.users.author.AuthorGridHandler" op="fetchGrid" submissionId=$submissionId escape=false}
			{load_url_in_div id="authorsGridContainer" url=$authorGridUrl}

			{$additionalContributorsFields}
		{/fbvFormArea}

		{url|assign:representationsGridUrl router=$smarty.const.ROUTE_COMPONENT component="grid.articleGalleys.ArticleGalleyGridHandler" op="fetchGrid" submissionId=$submissionId escape=false}
		{load_url_in_div id="formatsGridContainer"|uniqid url=$representationsGridUrl}

		{capture assign="cancelUrl"}{plugin_url path="cancelSubmit" submissionId="$submissionId"}{/capture}

		{fbvFormButtons id="quickSubmit" submitText="common.save" cancelUrl=$cancelUrl cancelUrlTarget="_self"}

	</form>
</div>


{include file="common/footer.tpl"}
